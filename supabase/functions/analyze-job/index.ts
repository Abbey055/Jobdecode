import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const jsonHeaders = {
  ...corsHeaders,
  "Content-Type": "application/json",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }

  try {
    const { jobUrl } = await req.json();
    const url = validateUrl(jobUrl);

    const html = await fetchHtml(url);
    const jobText = extractReadableText(html);

    if (jobText.length < 160) {
      return jsonResponse(
        { error: "We could not find enough job description text on that page." },
        422,
      );
    }

    const analysis = await analyzeWithGemini(jobText);
    const saved = await saveAnalysis(req, url.toString(), analysis);

    return jsonResponse({
      analysis: {
        id: saved?.id,
        jobUrl: url.toString(),
        ...analysis,
      },
    });
  } catch (error) {
    const message = error instanceof Error
      ? error.message
      : "We could not analyze this job right now.";
    return jsonResponse({ error: message }, 400);
  }
});

function jsonResponse(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: jsonHeaders,
  });
}

function validateUrl(value: unknown) {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new Error("Paste a valid job link.");
  }

  const url = new URL(value.trim());
  if (url.protocol !== "http:" && url.protocol !== "https:") {
    throw new Error("Only http and https job links are supported.");
  }

  return url;
}

async function fetchHtml(url: URL) {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 12000);

  try {
    const response = await fetch(url, {
      signal: controller.signal,
      headers: {
        "User-Agent":
          "Mozilla/5.0 (compatible; JobDecode/1.0; +https://jobdecode.app)",
        "Accept": "text/html,application/xhtml+xml",
      },
    });

    if (!response.ok) {
      throw new Error("The job page could not be opened.");
    }

    return await response.text();
  } finally {
    clearTimeout(timeout);
  }
}

function extractReadableText(html: string) {
  return html
    .replace(/<script[\s\S]*?<\/script>/gi, " ")
    .replace(/<style[\s\S]*?<\/style>/gi, " ")
    .replace(/<noscript[\s\S]*?<\/noscript>/gi, " ")
    .replace(/<[^>]+>/g, " ")
    .replace(/&nbsp;/g, " ")
    .replace(/&amp;/g, "&")
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'")
    .replace(/\s+/g, " ")
    .trim()
    .slice(0, 24000);
}

async function analyzeWithGemini(jobText: string) {
  const geminiApiKey = Deno.env.get("GEMINI_API_KEY");
  if (!geminiApiKey) {
    throw new Error("Analysis is temporarily unavailable. Please try again soon.");
  }

  const prompt = `Analyze the following job description.

Return valid JSON only. Do not include markdown, comments, explanations, or text outside the JSON object.

JSON shape:
{
  "jobTitle": "",
  "company": "",
  "location": "",
  "datePosted": "",
  "industry": "",
  "employmentType": "",
  "requiredSkills": [],
  "requiredEducation": "",
  "requiredExperience": "",
  "otherRequirements": [],
  "jobSummary": "",
  "simpleEnglishExplanation": "",
  "simpleLugandaExplanation": "",
  "mainTasks": [],
  "suitableCandidates": [],
  "difficultyLevel": "",
  "salaryEstimate": "",
  "responsibilities": [],
  "qualifications": [],
  "benefits": [],
  "confidenceScore": 0
}

Rules:
- Use simple beginner-friendly language.
- Write simpleLugandaExplanation in clear Luganda, not English.
- Summarize complex HR wording clearly.
- Extract only information present in the posting.
- If a field is not available, return an empty string or empty array.
- Difficulty level must be one of: Beginner, Intermediate, Advanced.
- confidenceScore must be a number from 0 to 100.
- Do not invent company names, salaries, locations, or requirements.

Job description:
${jobText}`;

  const endpoint =
    "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent";

  const response = await fetch(endpoint, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-goog-api-key": geminiApiKey,
    },
    body: JSON.stringify({
      contents: [{ role: "user", parts: [{ text: prompt }] }],
      generationConfig: {
        temperature: 0.2,
        responseMimeType: "application/json",
      },
    }),
  });

  if (!response.ok) {
    throw new Error("We could not finish analyzing this job. Please try again.");
  }

  const payload = await response.json();
  const text = payload?.candidates?.[0]?.content?.parts?.[0]?.text;

  if (typeof text !== "string") {
    throw new Error("We could not finish analyzing this job. Please try again.");
  }

  return normalizeAnalysis(JSON.parse(extractJsonObject(text)));
}

function extractJsonObject(text: string) {
  const start = text.indexOf("{");
  const end = text.lastIndexOf("}");
  if (start === -1 || end === -1 || end <= start) {
    throw new Error("We could not finish analyzing this job. Please try again.");
  }
  return text.slice(start, end + 1);
}

function normalizeAnalysis(value: Record<string, unknown>) {
  return {
    jobTitle: asString(value.jobTitle),
    company: asString(value.company),
    location: asString(value.location),
    datePosted: asString(value.datePosted),
    industry: asString(value.industry),
    employmentType: asString(value.employmentType),
    requiredSkills: asStringArray(value.requiredSkills),
    requiredEducation: asString(value.requiredEducation),
    requiredExperience: asString(value.requiredExperience),
    otherRequirements: asStringArray(value.otherRequirements),
    jobSummary: asString(value.jobSummary),
    simpleEnglishExplanation: asString(value.simpleEnglishExplanation),
    simpleLugandaExplanation: asString(value.simpleLugandaExplanation),
    mainTasks: asStringArray(value.mainTasks),
    suitableCandidates: asStringArray(value.suitableCandidates),
    difficultyLevel: normalizeDifficulty(value.difficultyLevel),
    salaryEstimate: asString(value.salaryEstimate),
    responsibilities: asStringArray(value.responsibilities),
    qualifications: asStringArray(value.qualifications),
    benefits: asStringArray(value.benefits),
    confidenceScore: asNumber(value.confidenceScore),
  };
}

async function saveAnalysis(
  req: Request,
  jobUrl: string,
  analysis: ReturnType<typeof normalizeAnalysis>,
) {
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const supabaseSecretKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ??
    Deno.env.get("SUPABASE_SECRET_KEY") ??
    getDefaultSupabaseSecretKey();

  if (!supabaseUrl || !supabaseSecretKey) {
    return null;
  }

  const supabase = createClient(supabaseUrl, supabaseSecretKey, {
    auth: { persistSession: false },
  });

  const authHeader = req.headers.get("Authorization");
  let userId: string | null = null;

  if (authHeader?.startsWith("Bearer ")) {
    const token = authHeader.replace("Bearer ", "");
    const { data } = await supabase.auth.getUser(token);
    userId = data.user?.id ?? null;
  }

  const { data, error } = await supabase
    .from("job_analyses")
    .insert({
      user_id: userId,
      job_url: jobUrl,
      job_title: analysis.jobTitle,
      company: analysis.company,
      location: analysis.location,
      industry: analysis.industry,
      employment_type: analysis.employmentType,
      required_experience: analysis.requiredExperience,
      required_education: analysis.requiredEducation,
      summary: analysis.jobSummary,
      simple_english: analysis.simpleEnglishExplanation,
      simple_luganda: analysis.simpleLugandaExplanation,
      analysis_json: analysis,
    })
    .select("id")
    .single();

  if (error) {
    return null;
  }

  return data;
}

function getDefaultSupabaseSecretKey() {
  const secretKeys = Deno.env.get("SUPABASE_SECRET_KEYS");
  if (!secretKeys) {
    return undefined;
  }

  try {
    const parsed = JSON.parse(secretKeys);
    if (typeof parsed.default === "string" && parsed.default.length > 0) {
      return parsed.default;
    }
  } catch {
    return undefined;
  }
}

function asString(value: unknown) {
  return typeof value === "string" ? value.trim() : "";
}

function asStringArray(value: unknown) {
  if (!Array.isArray(value)) {
    return [];
  }
  return value
    .map((item) => String(item).trim())
    .filter((item) => item.length > 0);
}

function asNumber(value: unknown) {
  if (typeof value === "number") {
    return Math.max(0, Math.min(100, Math.round(value)));
  }
  return 0;
}

function normalizeDifficulty(value: unknown) {
  const difficulty = asString(value);
  if (["Beginner", "Intermediate", "Advanced"].includes(difficulty)) {
    return difficulty;
  }
  return "";
}
