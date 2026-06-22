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
  "Content-Type": "application/json; charset=utf-8",
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

    const pageSignals = extractPageSignals(jobText);
    const analysis = applyPageSignals(
      await analyzeJob(jobText, pageSignals),
      pageSignals,
    );
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
  const text = html
    .replace(/<script[\s\S]*?<\/script>/gi, " ")
    .replace(/<style[\s\S]*?<\/style>/gi, " ")
    .replace(/<noscript[\s\S]*?<\/noscript>/gi, " ")
    .replace(/<li[^>]*>/gi, "\n- ")
    .replace(
      /<(?:br|\/p|\/div|\/li|\/ul|\/ol|\/h[1-6]|\/tr|\/table|\/section|\/article|\/blockquote)>/gi,
      "\n",
    )
    .replace(/<[^>]+>/g, " ")
    .replace(/\r/g, "\n");

  return decodeHtmlEntities(text)
    .replace(/\u2018|\u2019/g, "'")
    .replace(/\u201c|\u201d/g, '"')
    .replace(/\u2013|\u2014/g, "-")
    .replace(/\u00e2\u0080\u0098|\u00e2\u0080\u0099/g, "'")
    .replace(/\u00e2\u0080\u009c|\u00e2\u0080\u009d/g, '"')
    .replace(/\u00e2\u0080\u0093|\u00e2\u0080\u0094/g, "-")
    .replace(/[ \t\f\v]+/g, " ")
    .replace(/[ \t]*\n[ \t]*/g, "\n")
    .replace(/\n{2,}/g, "\n")
    .trim()
    .slice(0, 24000);
}

type PageSignals = {
  jobTitle: string;
  company: string;
  location: string;
  datePosted: string;
  applicationDeadline: string;
  postedBy: string;
  employmentType: string;
  requiredEducation: string;
  requiredExperience: string;
  salaryEstimate: string;
  industry: string;
};

function extractPageSignals(jobText: string): PageSignals {
  const detailLabels = jobDetailLabels();
  const requirementLines = extractSectionLines(jobText, [
    "Qualifications and Other Requirements",
    "Qualifications",
    "Requirements",
  ], [
    "Other Details",
    "Application procedure",
    "Please Note",
    "Date Posted",
    "More Jobs",
  ]);
  const company = extractLabeledValue(jobText, [
    "Hiring Organization",
    "Hiring Entity",
    "Posted By",
    "Employer",
    "Recruiter",
    "Organization",
    "Organisation",
    "Institution",
    "Company",
  ], detailLabels);

  return {
    jobTitle: extractLabeledValue(jobText, [
      "Job Title",
      "Title",
      "Position",
      "Role",
    ], detailLabels) || inferJobTitle(jobText),
    company,
    location: cleanLocationValue(extractLabeledValue(jobText, [
      "Location",
      "Duty Station",
      "Work Location",
    ], detailLabels)),
    datePosted: extractLabeledValue(jobText, [
      "Date Posted",
      "Posted Date",
      "Publication Date",
      "Published",
    ], detailLabels),
    applicationDeadline: cleanDeadlineValue(extractLabeledValue(jobText, [
      "Job Deadline",
      "Application Deadline",
      "Application Closing Date",
      "Closing Date",
      "Deadline",
      "Apply By",
      "Last Date",
      "Expiry Date",
    ], detailLabels)),
    postedBy: company || extractLabeledValue(jobText, [
      "Hiring Organization",
      "Hiring Entity",
      "Posted By",
      "Employer",
      "Recruiter",
      "Organization",
      "Organisation",
      "Institution",
    ], detailLabels),
    employmentType: cleanEmploymentType(extractLabeledValue(jobText, [
      "Employment Type",
      "Job Type",
      "Contract Type",
      "Work Hours",
    ], detailLabels)),
    requiredEducation: extractEducation(requirementLines) ||
      extractLabeledValue(jobText, [
        "Education",
        "Qualification",
        "Qualifications",
      ], detailLabels),
    requiredExperience: extractExperience(requirementLines) ||
      extractLabeledValue(jobText, [
        "Experience",
        "Required Experience",
        "Work Experience",
      ], detailLabels),
    salaryEstimate: cleanSalaryValue(extractLabeledValue(jobText, [
      "Salary",
      "Compensation",
      "Remuneration",
    ], detailLabels)),
    industry: inferIndustry(jobText),
  };
}

function extractLabeledValue(
  text: string,
  labels: string[],
  stopLabels: string[],
) {
  const lines = getTextLines(text);

  for (const line of lines) {
    for (const label of labels) {
      const pattern = new RegExp(
        `^(?:[-*]\\s*)?${labelPattern(label)}\\s*[:\\-]\\s*(.+)$`,
        "i",
      );
      const match = line.match(pattern);
      const value = cleanLabeledValue(match?.[1] ?? "");
      if (value.length > 0) {
        return value;
      }
    }
  }

  const normalizedText = text.replace(/\s+/g, " ").trim();
  const stopPattern = stopLabels.map(labelPattern).join("|");

  for (const label of labels) {
    const pattern = new RegExp(
      `(?:^|\\s)${labelPattern(label)}\\s*[:\\-]\\s*([\\s\\S]{1,160}?)(?=\\s+(?:${stopPattern})\\s*[:\\-]|$)`,
      "i",
    );
    const match = normalizedText.match(pattern);
    const value = cleanLabeledValue(match?.[1] ?? "");
    if (value.length > 0) {
      return value;
    }
  }

  return "";
}

function jobDetailLabels() {
  return [
    "Job Title",
    "Title",
    "Position",
    "Role",
    "Job Deadline",
    "Application Deadline",
    "Application Closing Date",
    "Closing Date",
    "Deadline",
    "Apply By",
    "Last Date",
    "Expiry Date",
    "Hiring Organization",
    "Hiring Entity",
    "Posted By",
    "Employer",
    "Company",
    "Organization",
    "Organisation",
    "Institution",
    "Recruiter",
    "Number of Jobs",
    "No. of Jobs",
    "No. of vacancies",
    "Vacancies",
    "Employment Type",
    "Contract Type",
    "Job Type",
    "Work Hours",
    "Salary",
    "Location",
    "Duty Station",
    "Education",
    "Qualification",
    "Qualifications",
    "Experience",
    "Required Experience",
    "Industry",
    "Date Posted",
    "Posted Date",
    "Publication Date",
    "Job Details",
  ];
}

function cleanLabeledValue(value: string) {
  const cleaned = value
    .replace(/\s+/g, " ")
    .replace(/^[\s:;\-]+/, "")
    .replace(/[\s;,.\-]+$/, "")
    .trim();

  const deduped = collapseRepeatedWords(cleaned);

  if (
    deduped.length === 0 ||
    deduped.length > 120 ||
    /^not\s+(listed|available|specified|stated)$/i.test(deduped)
  ) {
    return "";
  }

  return deduped;
}

function decodeHtmlEntities(value: string) {
  const namedEntities: Record<string, string> = {
    amp: "&",
    apos: "'",
    bull: "-",
    gt: ">",
    hellip: "...",
    laquo: '"',
    ldquo: '"',
    lrm: "",
    lsquo: "'",
    lt: "<",
    mdash: "-",
    ndash: "-",
    nbsp: " ",
    quot: '"',
    raquo: '"',
    rdquo: '"',
    rlm: "",
    rsquo: "'",
  };

  return value
    .replace(/&#x([0-9a-f]+);/gi, (_, code) => decodeCodePoint(code, 16))
    .replace(/&#(\d+);/g, (_, code) => decodeCodePoint(code, 10))
    .replace(/&([a-z]+);/gi, (match, name) =>
      namedEntities[name.toLowerCase()] ?? match
    );
}

function decodeCodePoint(value: string, radix: number) {
  const codePoint = Number.parseInt(value, radix);
  if (!Number.isFinite(codePoint)) {
    return "";
  }

  try {
    return String.fromCodePoint(codePoint);
  } catch {
    return "";
  }
}

function collapseRepeatedWords(value: string) {
  const words = value.split(/\s+/);

  for (
    let chunkSize = Math.floor(words.length / 2);
    chunkSize >= 1;
    chunkSize--
  ) {
    if (words.length % chunkSize !== 0) {
      continue;
    }

    const firstChunk = words.slice(0, chunkSize).join(" ");
    const isRepeated = words.every((word, index) =>
      word.toLowerCase() === words[index % chunkSize].toLowerCase()
    );

    if (isRepeated) {
      return firstChunk;
    }
  }

  return value;
}

function labelPattern(label: string) {
  return regexEscape(label).replace(/\s+/g, "\\s+");
}

function regexEscape(value: string) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function getTextLines(text: string) {
  return text
    .split(/\n+/)
    .map((line) => line.replace(/\s+/g, " ").trim())
    .filter((line) => line.length > 0);
}

function stripListMarker(value: string) {
  return value.replace(/^[-*\d.)\s]+/, "").trim();
}

function normalizeHeading(value: string) {
  return stripListMarker(value)
    .replace(/[:\-]+$/, "")
    .replace(/\s+/g, " ")
    .trim()
    .toLowerCase();
}

function matchesHeading(line: string, headings: string[]) {
  const normalized = normalizeHeading(line);
  return headings.some((heading) =>
    normalized === heading.toLowerCase() ||
    normalized.startsWith(`${heading.toLowerCase()} `)
  );
}

function extractSectionLines(
  text: string,
  startHeadings: string[],
  endHeadings: string[],
) {
  const lines = getTextLines(text);
  const values: string[] = [];
  let inSection = false;

  for (const line of lines) {
    if (!inSection && matchesHeading(line, startHeadings)) {
      inSection = true;
      continue;
    }

    if (!inSection) {
      continue;
    }

    if (matchesHeading(line, endHeadings)) {
      break;
    }

    const value = cleanSectionLine(line);
    if (value.length > 0) {
      values.push(value);
    }
  }

  return values;
}

function cleanSectionLine(value: string) {
  const cleaned = stripListMarker(value)
    .replace(/\s+/g, " ")
    .trim();

  if (
    cleaned.length === 0 ||
    /^job details:?$/i.test(cleaned) ||
    /^background:?$/i.test(cleaned)
  ) {
    return "";
  }

  return cleaned;
}

function inferJobTitle(text: string) {
  for (const line of getTextLines(text)) {
    const value = stripListMarker(line);
    const postMatch = value.match(/^(.+?)\s+job\s+post$/i);
    if (postMatch) {
      return cleanJobTitle(postMatch[1]);
    }

    const atMatch = value.match(/^(.+?)\s+job\s+at\s+/i);
    if (atMatch) {
      return cleanJobTitle(atMatch[1]);
    }
  }

  return "";
}

function cleanJobTitle(value: string) {
  return value
    .replace(/\s+/g, " ")
    .replace(/\bpost$/i, "")
    .trim();
}

function cleanLocationValue(value: string) {
  const cleaned = value.replace(/\s+/g, " ").trim();
  const ugandaMatch = cleaned.match(/\bUganda\b/i);
  if (/^jobs?\s+in\s+uganda\b/i.test(cleaned) && ugandaMatch) {
    return "Uganda";
  }
  return cleaned;
}

function cleanEmploymentType(value: string) {
  const cleaned = value.replace(/\s+/g, " ").trim();
  const match = cleaned.match(
    /\b(full[-\s]?time|part[-\s]?time|contract|internship|temporary|permanent|consultancy)\b/i,
  );
  if (!match) {
    return cleaned;
  }

  const normalized = match[1].toLowerCase().replace(/\s+/, "-");
  if (normalized === "full-time") {
    return "Full-time";
  }
  if (normalized === "part-time") {
    return "Part-time";
  }
  return normalizeTitleCase(normalized);
}

function cleanDeadlineValue(value: string) {
  const cleaned = value.replace(/\s+/g, " ").trim();
  const dateMatch = cleaned.match(
    /\b(?:\d{4}-\d{2}-\d{2}|[A-Za-z]+\s+\d{1,2},?\s+\d{4}|\d{1,2}(?:st|nd|rd|th)?\s+[A-Za-z]+\s+\d{4})\b/,
  );
  return dateMatch ? dateMatch[0].replace(",", "") : cleaned;
}

function cleanSalaryValue(value: string) {
  const cleaned = value.replace(/\s+/g, " ").trim();
  if (/^(ugx|usd|not\s+(listed|specified|stated))$/i.test(cleaned)) {
    return "";
  }
  return cleaned;
}

function extractEducation(lines: string[]) {
  return lines
    .filter((line) =>
      /\b(degree|diploma|qualification|icsa|uls|practicing certificate|university|institution)\b/i
        .test(line)
    )
    .slice(0, 5)
    .join("; ");
}

function extractExperience(lines: string[]) {
  return lines.find((line) => /\bexperience\b/i.test(line)) ?? "";
}

function extractOtherRequirements(lines: string[]) {
  const education = new Set(extractEducation(lines).split("; ").filter(Boolean));
  const experience = extractExperience(lines);

  return lines
    .filter((line) => !education.has(line) && line !== experience)
    .slice(0, 8);
}

function inferIndustry(text: string) {
  if (/\b(government agency|bureau of standards|regulatory|standardization|quality assurance)\b/i.test(text)) {
    return "Government/Regulatory";
  }
  return "";
}

function normalizeTitleCase(value: string) {
  return value
    .toLowerCase()
    .split("-")
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join("-");
}

function applyPageSignals(
  analysis: ReturnType<typeof normalizeAnalysis>,
  pageSignals: PageSignals,
) {
  return {
    ...analysis,
    jobTitle: analysis.jobTitle || pageSignals.jobTitle,
    company: analysis.company || pageSignals.company,
    location: analysis.location || pageSignals.location,
    datePosted: analysis.datePosted || pageSignals.datePosted,
    applicationDeadline:
      pageSignals.applicationDeadline || analysis.applicationDeadline,
    postedBy: pageSignals.postedBy || analysis.postedBy,
    industry: analysis.industry || pageSignals.industry,
    employmentType: analysis.employmentType || pageSignals.employmentType,
    requiredEducation:
      analysis.requiredEducation || pageSignals.requiredEducation,
    requiredExperience:
      analysis.requiredExperience || pageSignals.requiredExperience,
    salaryEstimate: analysis.salaryEstimate || pageSignals.salaryEstimate,
  };
}

async function analyzeJob(jobText: string, pageSignals: PageSignals) {
  if (Deno.env.get("GROQ_API_KEY")) {
    try {
      return await analyzeWithGroq(jobText, pageSignals);
    } catch (error) {
      console.error("Groq analysis failed", errorForLogs(error));
    }
  }

  try {
    return await analyzeWithGemini(jobText, pageSignals);
  } catch (error) {
    console.error("Gemini analysis failed", errorForLogs(error));
    return analyzeWithoutAi(jobText, pageSignals);
  }
}

async function analyzeWithGroq(jobText: string, pageSignals: PageSignals) {
  const groqApiKey = Deno.env.get("GROQ_API_KEY");
  if (!groqApiKey) {
    throw new Error("Missing GROQ_API_KEY");
  }

  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 25000);
  const response = await fetch(
    "https://api.groq.com/openai/v1/chat/completions",
    {
      method: "POST",
      signal: controller.signal,
      headers: {
        "Authorization": `Bearer ${groqApiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: "llama-3.3-70b-versatile",
        messages: [
          {
            role: "system",
            content:
              "You extract job posting information. Return valid JSON only.",
          },
          { role: "user", content: buildAnalysisPrompt(jobText, pageSignals) },
        ],
        temperature: 0.2,
        response_format: { type: "json_object" },
      }),
    },
  ).finally(() => clearTimeout(timeout));

  if (!response.ok) {
    const body = await response.text();
    throw new Error(`Groq returned ${response.status}: ${body.slice(0, 700)}`);
  }

  const payload = await response.json();
  const text = payload?.choices?.[0]?.message?.content;

  if (typeof text !== "string") {
    throw new Error("Groq returned an empty analysis response");
  }

  return normalizeAnalysis(JSON.parse(extractJsonObject(text)));
}

function buildAnalysisPrompt(jobText: string, pageSignals: PageSignals) {
  const detectedFields = [
    pageSignals.jobTitle ? `jobTitle: ${pageSignals.jobTitle}` : "",
    pageSignals.company ? `company: ${pageSignals.company}` : "",
    pageSignals.location ? `location: ${pageSignals.location}` : "",
    pageSignals.datePosted ? `datePosted: ${pageSignals.datePosted}` : "",
    pageSignals.applicationDeadline
      ? `applicationDeadline: ${pageSignals.applicationDeadline}`
      : "",
    pageSignals.postedBy ? `postedBy: ${pageSignals.postedBy}` : "",
    pageSignals.employmentType
      ? `employmentType: ${pageSignals.employmentType}`
      : "",
    pageSignals.requiredExperience
      ? `requiredExperience: ${pageSignals.requiredExperience}`
      : "",
    pageSignals.requiredEducation
      ? `requiredEducation: ${pageSignals.requiredEducation}`
      : "",
  ].filter(Boolean).join("\n") || "None";

  return `Analyze the following job description.

Return valid JSON only. Do not include markdown, comments, explanations, or text outside the JSON object.

JSON shape:
{
  "jobTitle": "",
  "company": "",
  "location": "",
  "datePosted": "",
  "applicationDeadline": "",
  "postedBy": "",
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
- applicationDeadline means the deadline for applying or sending the application. Use labels such as Job Deadline, Application Deadline, Closing Date, Apply By, or Last Date. Do not use the posting/publication date for this field.
- applicationDeadline should include the closing date and time when both are present.
- postedBy should use the Hiring Entity, employer, named person, department, recruiter, platform account, or organization responsible for the job posting when stated.
- If a field is not available, return an empty string or empty array.
- Difficulty level must be one of: Beginner, Intermediate, Advanced.
- confidenceScore must be a number from 0 to 100.
- Do not invent company names, salaries, locations, or requirements.

Detected labeled fields from the page:
${detectedFields}

Job description:
${jobText}`;
}

async function analyzeWithGemini(jobText: string, pageSignals: PageSignals) {
  const geminiApiKey = Deno.env.get("GEMINI_API_KEY");
  if (!geminiApiKey) {
    throw new Error("Missing GEMINI_API_KEY");
  }

  const prompt = buildAnalysisPrompt(jobText, pageSignals);

  const endpoint =
    "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent";

  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 25000);
  const response = await fetch(endpoint, {
    method: "POST",
    signal: controller.signal,
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
  }).finally(() => clearTimeout(timeout));

  if (!response.ok) {
    const body = await response.text();
    throw new Error(
      `Gemini returned ${response.status}: ${body.slice(0, 700)}`,
    );
  }

  const payload = await response.json();
  const text = payload?.candidates?.[0]?.content?.parts?.[0]?.text;

  if (typeof text !== "string") {
    throw new Error("Gemini returned an empty analysis response");
  }

  return normalizeAnalysis(JSON.parse(extractJsonObject(text)));
}

function extractJsonObject(text: string) {
  const start = text.indexOf("{");
  const end = text.lastIndexOf("}");
  if (start === -1 || end === -1 || end <= start) {
    throw new Error("Gemini returned a non-JSON analysis response");
  }
  return text.slice(start, end + 1);
}

function analyzeWithoutAi(jobText: string, pageSignals: PageSignals) {
  const detailLabels = jobDetailLabels();
  const requirementLines = extractSectionLines(jobText, [
    "Qualifications and Other Requirements",
    "Qualifications",
    "Requirements",
  ], [
    "Other Details",
    "Application procedure",
    "Please Note",
    "Date Posted",
    "More Jobs",
  ]);
  const skills = extractSkills(jobText);
  const responsibilities = extractSectionLines(jobText, [
    "Responsibilities",
    "Duties",
    "Key Responsibilities",
  ], [
    "Qualifications and Other Requirements",
    "Qualifications",
    "Requirements",
    "Other Details",
    "Application procedure",
  ]).slice(0, 8);
  const qualifications = requirementLines.length > 0
    ? requirementLines.slice(0, 10)
    : extractSentencesByWords(jobText, [
      "degree",
      "diploma",
      "certificate",
      "experience",
      "knowledge",
      "ability",
      "skill",
      "required",
    ], 5);
  const benefits = extractSentencesByWords(jobText, [
    "benefit",
    "salary",
    "allowance",
    "insurance",
    "leave",
  ], 4);
  const jobTitle = pageSignals.jobTitle || extractLabeledValue(jobText, [
    "Job Title",
    "Title",
    "Position",
    "Role",
  ], detailLabels);
  const company = pageSignals.company || pageSignals.postedBy ||
    extractLabeledValue(jobText, [
      "Hiring Organization",
      "Hiring Entity",
      "Posted By",
      "Employer",
      "Recruiter",
      "Company",
      "Organization",
      "Organisation",
      "Institution",
    ], detailLabels);
  const location = pageSignals.location || cleanLocationValue(
    extractLabeledValue(jobText, [
      "Location",
      "Duty Station",
      "Work Location",
    ], detailLabels),
  );
  const employmentType = pageSignals.employmentType || cleanEmploymentType(
    extractLabeledValue(jobText, [
      "Employment Type",
      "Job Type",
      "Contract Type",
      "Work Hours",
    ], detailLabels),
  );
  const requiredEducation = pageSignals.requiredEducation ||
    extractEducation(requirementLines) ||
    extractLabeledValue(jobText, [
      "Education",
      "Qualification",
      "Qualifications",
    ], detailLabels);
  const requiredExperience = pageSignals.requiredExperience ||
    extractExperience(requirementLines) ||
    extractLabeledValue(jobText, [
      "Experience",
      "Required Experience",
      "Work Experience",
    ], detailLabels);
  const otherRequirements = extractOtherRequirements(requirementLines);
  const salaryEstimate = pageSignals.salaryEstimate ||
    cleanSalaryValue(
      extractLabeledValue(jobText, [
        "Salary",
        "Compensation",
        "Remuneration",
      ], detailLabels),
    );
  const summary = summarizeText(
    extractSectionLines(jobText, [
      "Background",
      "Job Details",
    ], [
      "Responsibilities",
      "Duties",
      "Qualifications and Other Requirements",
    ]).join(" ") || jobText,
  );
  const roleName = jobTitle || "this role";
  const organization = company ? ` at ${company}` : "";

  return normalizeAnalysis({
    jobTitle,
    company,
    location,
    datePosted: pageSignals.datePosted || extractLabeledValue(jobText, [
      "Date Posted",
      "Posted Date",
      "Publication Date",
      "Published",
    ], detailLabels),
    applicationDeadline: pageSignals.applicationDeadline,
    postedBy: pageSignals.postedBy || company,
    industry: pageSignals.industry,
    employmentType,
    requiredSkills: skills,
    requiredEducation,
    requiredExperience,
    otherRequirements,
    jobSummary: summary,
    simpleEnglishExplanation:
      `${roleName}${organization} needs someone who can handle the listed duties and meet the stated requirements. Review the original posting before applying.`,
    simpleLugandaExplanation:
      `Omulimu guno gwa ${roleName}${organization}. Soma ebisaanyizo, obuvunaanyizibwa, n'ekiseera ky'okusaba nga tonnasaba.`,
    mainTasks: responsibilities.length > 0 ? responsibilities : [summary],
    suitableCandidates: qualifications,
    difficultyLevel: estimateDifficulty(requiredExperience),
    salaryEstimate,
    responsibilities,
    qualifications,
    benefits,
    confidenceScore: 60,
  });
}

function extractSkills(text: string) {
  const skillKeywords = [
    "communication",
    "customer service",
    "leadership",
    "project management",
    "data analysis",
    "microsoft office",
    "excel",
    "sales",
    "marketing",
    "accounting",
    "finance",
    "procurement",
    "monitoring and evaluation",
    "research",
    "report writing",
    "problem solving",
    "teamwork",
    "training",
    "administration",
    "computer skills",
    "legal advice",
    "legal practice",
    "litigation",
    "risk management",
  ];
  const normalized = text.toLowerCase();
  return skillKeywords
    .filter((skill) => normalized.includes(skill))
    .slice(0, 10)
    .map((skill) => skill.replace(/\b\w/g, (letter) => letter.toUpperCase()));
}

function extractSentencesByWords(
  text: string,
  words: string[],
  limit: number,
) {
  const normalizedWords = words.map((word) => word.toLowerCase());
  return splitSentences(text)
    .filter((sentence) => {
      const normalized = sentence.toLowerCase();
      return normalizedWords.some((word) => normalized.includes(word));
    })
    .map(shortenSentence)
    .filter((sentence, index, sentences) =>
      sentence.length > 0 && sentences.indexOf(sentence) === index
    )
    .slice(0, limit);
}

function splitSentences(text: string) {
  return text
    .replace(/\s+/g, " ")
    .split(/(?<=[.!?])\s+/)
    .map((sentence) => sentence.trim())
    .filter((sentence) => sentence.length >= 35 && sentence.length <= 260);
}

function shortenSentence(sentence: string) {
  return sentence
    .replace(/\s+/g, " ")
    .replace(/^[\-*\s]+/, "")
    .trim()
    .slice(0, 220);
}

function summarizeText(text: string) {
  const sentences = splitSentences(text).slice(0, 2);
  if (sentences.length > 0) {
    return sentences.join(" ").slice(0, 420);
  }
  return text.replace(/\s+/g, " ").trim().slice(0, 360);
}

function estimateDifficulty(requiredExperience: string) {
  const text = requiredExperience.toLowerCase();
  const years = text.match(/(?:\((\d+)\)|(\d+))\s*\+?\s*(?:years|yrs)/);
  const yearCount = years ? Number(years[1] ?? years[2]) : 0;
  if (yearCount >= 5 || text.includes("senior") || text.includes("advanced")) {
    return "Advanced";
  }
  if (yearCount >= 2 || text.includes("mid") || text.includes("intermediate")) {
    return "Intermediate";
  }
  return "Beginner";
}

function errorForLogs(error: unknown) {
  if (error instanceof Error) {
    return {
      name: error.name,
      message: error.message,
      stack: error.stack,
    };
  }
  return { message: String(error) };
}

function normalizeAnalysis(value: Record<string, unknown>) {
  return {
    jobTitle: asString(value.jobTitle),
    company: asString(value.company),
    location: asString(value.location),
    datePosted: asString(value.datePosted),
    applicationDeadline: asString(value.applicationDeadline),
    postedBy: asString(value.postedBy),
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

