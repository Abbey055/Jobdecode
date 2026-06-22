# JOBDECODE

### Smart Job Understanding Platform

Prepared by: Ssenkubuge Abbey

## Overview

JobDecode is a mobile platform designed to simplify job searching by helping users understand job advertisements in a clear and simple way.

Many job seekers struggle to interpret complex job descriptions filled with technical language, unclear requirements, and long explanations. JobDecode solves this by breaking down job posts into simple, understandable insights.

## Problem

Job seekers often face challenges such as:

- Difficult and confusing job descriptions
- Unclear requirements
- Unfamiliar job titles
- Lack of understanding of what employers actually want
- Wasting time on unsuitable job applications
- Low confidence when applying

## Solution

JobDecode transforms job advertisements into:

- Simple explanations
- Clear skill requirements
- Easy-to-understand job summaries
- Suitability guidance for applicants

## Objectives

- Simplify job descriptions
- Help users identify required skills
- Improve job application confidence
- Save time during job search
- Help users understand suitable roles

## Target Users

- University students
- Fresh graduates
- Job seekers

## How It Works

1. User finds a job link
2. User submits the link in JobDecode
3. System analyzes job information
4. User receives a simplified breakdown including:
   - Job title
   - Company
   - Location
   - Requirements
   - Skills
   - Responsibilities
   - Simple explanation

## Core Features

- Job link analysis
- Job summary breakdown
- Skills identification
- Requirement categorization
- Simple English explanation
- Luganda explanation
- Candidate suitability guide
- Job history tracking
- Save jobs for later
- Email and phone code sign-in

## Key Challenges Solved

- Confusing job descriptions simplified
- Career confusion reduced
- Time spent on job search reduced
- Application confidence improved

## Impact

JobDecode helps users:

- Make better career decisions
- Understand job requirements clearly
- Apply with confidence
- Transition smoothly from education to employment

## Future Improvements

- CV improvement tools
- Skill gap analysis
- Interview preparation
- Career recommendations
- Job alerts system
- Application tracking

## Tech Stack

- Flutter
- Supabase Auth
- Supabase Database
- Supabase Edge Functions

## Android Build

The release APK is generated locally at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

For public distribution, upload the APK to GitHub Releases instead of committing build output to the repository.

## Local Development

```sh
flutter pub get
flutter run
```

## Supabase

Project ref:

```text
wtnegfrmbrhvukrtonah
```

Apply database migrations:

```sh
npx supabase db push --linked
```

Deploy the analysis function:

```sh
npx supabase functions deploy analyze-job --project-ref wtnegfrmbrhvukrtonah --no-verify-jwt
```

Secrets must be stored only in Supabase function secrets. Do not commit private API keys.

## Conclusion

JobDecode bridges the gap between job seekers and job opportunities by making job descriptions simple, clear, and actionable.
