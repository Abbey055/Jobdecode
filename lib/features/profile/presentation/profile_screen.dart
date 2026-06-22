import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_config.dart';
import '../../../features/analysis/presentation/providers/analysis_providers.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/app_screen.dart';
import '../../../shared/widgets/ui_kit.dart';

enum _CodeChannel { email, phone }

const _gmailRed = Color(0xFFEA4335);
const _phoneGreen = Color(0xFF34A853);

class _DialCode {
  const _DialCode(this.flag, this.country, this.code);

  final String flag;
  final String country;
  final String code;
}

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  static const _dialCodes = [
    _DialCode('🇺🇬', 'Uganda', '+256'),
    _DialCode('🇰🇪', 'Kenya', '+254'),
    _DialCode('🇹🇿', 'Tanzania', '+255'),
    _DialCode('🇷🇼', 'Rwanda', '+250'),
    _DialCode('🇺🇸', 'United States', '+1'),
    _DialCode('🇬🇧', 'United Kingdom', '+44'),
  ];

  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();

  _CodeChannel _channel = _CodeChannel.email;
  String _countryCode = '+256';
  String? _sentTo;
  _CodeChannel? _sentChannel;
  String? _accountNotice;
  bool _busy = false;

  int get _activeCodeLength => _codeLengthFor(_channel);

  int get _sentCodeLength => _codeLengthFor(_sentChannel ?? _channel);

  int _codeLengthFor(_CodeChannel channel) {
    return channel == _CodeChannel.email ? 8 : 6;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (!await AppConfig.ensureSupabaseReady()) {
      _setAccountNotice('Please check your connection and try again.');
      return;
    }

    final destination = _readDestination();
    if (destination == null) {
      return;
    }

    setState(() {
      _busy = true;
      _accountNotice = null;
    });
    try {
      await _requestCode(channel: _channel, destination: destination);

      setState(() {
        _sentTo = destination;
        _sentChannel = _channel;
        _codeController.clear();
        _accountNotice = null;
      });
      _show('We sent a $_activeCodeLength-digit code.');
    } on AuthException catch (error) {
      final message = _friendlyAuthMessage(error.message);
      if (_channel == _CodeChannel.phone ||
          error.message.toLowerCase().contains('phone')) {
        _setAccountNotice(message);
      } else {
        _show(message);
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _resendCode() async {
    final sentTo = _sentTo;
    final sentChannel = _sentChannel;
    if (sentTo == null || sentChannel == null) {
      _setAccountNotice('Send a code first.');
      return;
    }

    if (!await AppConfig.ensureSupabaseReady()) {
      _setAccountNotice('Please check your connection and try again.');
      return;
    }

    setState(() {
      _busy = true;
      _accountNotice = null;
    });
    try {
      await _requestCode(channel: sentChannel, destination: sentTo);
      setState(() => _codeController.clear());
      _show('We sent another ${_codeLengthFor(sentChannel)}-digit code.');
    } on AuthException catch (error) {
      final message = _friendlyAuthMessage(error.message);
      if (sentChannel == _CodeChannel.phone ||
          error.message.toLowerCase().contains('phone')) {
        _setAccountNotice(message);
      } else {
        _show(message);
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _requestCode({
    required _CodeChannel channel,
    required String destination,
  }) async {
    if (channel == _CodeChannel.email) {
      await AppConfig.supabaseClientOrNull!.auth.signInWithOtp(
        email: destination,
        shouldCreateUser: true,
        data: const {'app_name': 'JobDecode'},
      );
    } else {
      await AppConfig.supabaseClientOrNull!.auth.signInWithOtp(
        phone: destination,
        shouldCreateUser: true,
        channel: OtpChannel.sms,
        data: const {'app_name': 'JobDecode'},
      );
    }
  }

  Future<void> _verifyCode() async {
    if (!await AppConfig.ensureSupabaseReady()) {
      _show('Please check your connection and try again.');
      return;
    }

    if (_sentTo == null || _sentChannel == null) {
      _show('Send a code first.');
      return;
    }

    final code = _codeController.text.trim();
    if (!RegExp('^\\d{$_sentCodeLength}\$').hasMatch(code)) {
      _show('Enter the $_sentCodeLength-digit code.');
      return;
    }

    setState(() => _busy = true);
    try {
      if (_sentChannel == _CodeChannel.email) {
        await AppConfig.supabaseClientOrNull!.auth.verifyOTP(
          email: _sentTo,
          token: code,
          type: OtpType.email,
        );
      } else {
        await AppConfig.supabaseClientOrNull!.auth.verifyOTP(
          phone: _sentTo,
          token: code,
          type: OtpType.sms,
        );
      }

      _refreshAccountData();
      if (!mounted) {
        return;
      }
      setState(() {
        _busy = false;
        _clearAuthInputs();
      });
      _show('Signed in.');
      context.go('/saved');
    } on AuthException catch (error) {
      _show(_friendlyAuthMessage(error.message));
    } finally {
      if (mounted && _busy) {
        setState(() => _busy = false);
      }
    }
  }

  void _clearAuthInputs() {
    _emailController.clear();
    _phoneController.clear();
    _codeController.clear();
    _sentTo = null;
    _sentChannel = null;
    _accountNotice = null;
  }

  String? _readDestination() {
    if (_channel == _CodeChannel.email) {
      final email = _emailController.text.trim();
      final hasValidEmail = RegExp(
        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
      ).hasMatch(email);

      if (!hasValidEmail) {
        _setAccountNotice('Enter a valid email address.');
        return null;
      }

      return email;
    }

    final rawPhone = _phoneController.text.trim();
    final digits = rawPhone.replaceAll(RegExp(r'\D'), '');
    final nationalNumber = digits.replaceFirst(RegExp(r'^0+'), '');
    final destination = rawPhone.startsWith('+')
        ? '+$digits'
        : '$_countryCode$nationalNumber';
    final hasValidPhone = RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(destination);

    if (!hasValidPhone) {
      _setAccountNotice('Enter a valid phone number.');
      return null;
    }

    return destination;
  }

  String _friendlyAuthMessage(String message) {
    final lower = message.toLowerCase();

    if (lower.contains('token') ||
        lower.contains('otp') ||
        lower.contains('expired')) {
      return 'That code did not work. Try a new code.';
    }
    if (lower.contains('phone')) {
      return 'Text message sign-in is not available right now. Use email to continue.';
    }
    if (lower.contains('email')) {
      return 'Check your email address and try again.';
    }
    if (lower.contains('rate') || lower.contains('too many')) {
      return 'Too many tries. Please wait a moment.';
    }

    return 'We could not complete this. Please try again.';
  }

  Future<void> _signOut() async {
    if (!await AppConfig.ensureSupabaseReady()) {
      return;
    }
    await AppConfig.supabaseClientOrNull!.auth.signOut();
    _refreshAccountData();
    setState(() {});
  }

  void _refreshAccountData() {
    ref.invalidate(isSignedInProvider);
    ref.invalidate(historyProvider);
    ref.invalidate(savedAnalysesProvider);
    ref.invalidate(savedJobIdsProvider);
  }

  void _setAccountNotice(String message) {
    if (!mounted) {
      return;
    }
    setState(() => _accountNotice = message);
  }

  void _show(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(isSignedInProvider);
    final user = AppConfig.supabaseClientOrNull?.auth.currentUser;
    final isCodeSent = _sentTo != null;

    return AppScreen(
      currentIndex: 3,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Profile',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 22),
            JDCard(
              child: Row(
                children: [
                  _ProfileAvatar(user: user),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user == null ? 'Guest profile' : 'Signed in',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ??
                              user?.phone ??
                              'Sign in to save jobs across devices.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            JDCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 14),
                  SegmentedButton<_CodeChannel>(
                    segments: [
                      const ButtonSegment(
                        value: _CodeChannel.email,
                        icon: _ChannelIcon(
                          icon: Icons.mail_rounded,
                          color: _gmailRed,
                        ),
                        label: Text('Gmail'),
                      ),
                      const ButtonSegment(
                        value: _CodeChannel.phone,
                        icon: _ChannelIcon(
                          icon: Icons.phone_iphone_rounded,
                          color: _phoneGreen,
                        ),
                        label: Text('Phone'),
                      ),
                    ],
                    selected: {_channel},
                    onSelectionChanged: _busy
                        ? null
                        : (selection) {
                            setState(() {
                              _channel = selection.first;
                              _sentTo = null;
                              _sentChannel = null;
                              _accountNotice = null;
                              _codeController.clear();
                            });
                          },
                  ),
                  const SizedBox(height: 14),
                  if (_channel == _CodeChannel.email)
                    TextField(
                      controller: _emailController,
                      autofillHints: const [AutofillHints.email],
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _sendCode(),
                      decoration: const InputDecoration(
                        hintText: 'Gmail address',
                        prefixIcon: Icon(Icons.mail_rounded, color: _gmailRed),
                      ),
                    )
                  else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 126,
                          child: DropdownButtonFormField<String>(
                            initialValue: _countryCode,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 14,
                              ),
                            ),
                            selectedItemBuilder: (context) {
                              return _dialCodes.map((country) {
                                return _CountryCodeLabel(
                                  flag: country.flag,
                                  label: country.code,
                                );
                              }).toList();
                            },
                            items: _dialCodes.map((country) {
                              return DropdownMenuItem(
                                value: country.code,
                                child: _CountryCodeLabel(
                                  flag: country.flag,
                                  label: '${country.country} ${country.code}',
                                ),
                              );
                            }).toList(),
                            onChanged: _busy
                                ? null
                                : (value) {
                                    if (value != null) {
                                      setState(() => _countryCode = value);
                                    }
                                  },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            autofillHints: const [
                              AutofillHints.telephoneNumberNational,
                            ],
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _sendCode(),
                            decoration: const InputDecoration(
                              hintText: '700000000',
                              prefixIcon: Icon(
                                Icons.phone_iphone_rounded,
                                color: _phoneGreen,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (_accountNotice != null) ...[
                    const SizedBox(height: 12),
                    _AccountNotice(message: _accountNotice!),
                  ],
                  const SizedBox(height: 14),
                  PrimaryAction(
                    label: _busy
                        ? 'Please wait...'
                        : 'Send $_activeCodeLength-digit Code',
                    onPressed: _busy ? null : _sendCode,
                  ),
                  if (user != null) ...[
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: _signOut,
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Sign Out'),
                    ),
                  ],
                ],
              ),
            ),
            if (isCodeSent) ...[
              const SizedBox(height: 16),
              JDCard(
                backgroundColor: const Color(0xFFF8FAFF),
                borderColor: const Color(0xFFC7D2FE),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const IconBadge(
                          icon: Icons.pin_rounded,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Enter your code',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Sent to $_sentTo',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.muted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _codeController,
                      autofillHints: const [AutofillHints.oneTimeCode],
                      keyboardType: TextInputType.number,
                      maxLength: _sentCodeLength,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _verifyCode(),
                      decoration: InputDecoration(
                        hintText: '$_sentCodeLength-digit code',
                        counterText: '',
                        prefixIcon: const Icon(Icons.verified_user_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _busy ? null : _verifyCode,
                      icon: const Icon(Icons.verified_rounded),
                      label: const Text('Verify Code'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: TextButton.icon(
                        onPressed: _busy ? null : _resendCode,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Resend code'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            const JDCard(
              backgroundColor: AppColors.soft,
              child: Row(
                children: [
                  IconBadge(
                    icon: Icons.verified_user_rounded,
                    color: AppColors.secondary,
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Your jobs can be saved and opened again later.',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.user});

  final User? user;

  @override
  Widget build(BuildContext context) {
    final imageUrl = _profileImageUrl(user);
    final label = user?.email ?? user?.phone ?? '';
    final initial = label.trim().isEmpty ? '?' : label.trim()[0].toUpperCase();

    Widget fallback() {
      if (user == null) {
        return const Icon(
          Icons.person_outline_rounded,
          color: AppColors.primary,
          size: 28,
        );
      }

      return Text(
        initial,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      );
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl == null
          ? Center(child: fallback())
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(child: fallback());
              },
            ),
    );
  }

  String? _profileImageUrl(User? user) {
    final metadata = user?.userMetadata;
    if (metadata == null) {
      return null;
    }

    for (final key in ['avatar_url', 'picture', 'photo_url']) {
      final value = metadata[key]?.toString().trim();
      final uri = Uri.tryParse(value ?? '');
      if (value != null &&
          value.isNotEmpty &&
          uri != null &&
          (uri.scheme == 'http' || uri.scheme == 'https') &&
          uri.host.isNotEmpty) {
        return value;
      }
    }

    return null;
  }
}

class _ChannelIcon extends StatelessWidget {
  const _ChannelIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }
}

class _AccountNotice extends StatelessWidget {
  const _AccountNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.soft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountryCodeLabel extends StatelessWidget {
  const _CountryCodeLabel({required this.flag, required this.label});

  final String flag;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(flag, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
