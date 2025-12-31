import OpenAI from "openai";

// Lazy initialization - only create the client when needed
let _client: OpenAI | null = null;
const getClient = (): OpenAI => {
  if (!_client) {
    const apiKey = process.env.OPENAI_API_KEY;
    if (!apiKey) {
      throw new Error("OPENAI_API_KEY 환경 변수가 설정되지 않았습니다. .env 파일에 OPENAI_API_KEY를 설정해주세요.");
    }
    _client = new OpenAI({ apiKey, dangerouslyAllowBrowser: true });
  }
  return _client;
};

/**
 * 기업 취업규칙 내 괴롭힘 방지 조항 생성 (GPT-4o-mini)
 */
export const generateEmploymentRule = async (companyName: string) => {
  const prompt = `주식회사 "${companyName}"를 위한 최신 노동법 기준 직장 내 괴롭힘 방지 조항을 생성하라.
  반드시 포함할 내용:
  1. 괴롭힘의 정의 (최신 판례 반영)
  2. 금지되는 구체적 행위 양태 (폭언, 업무배제, 모욕 등)
  3. 신고 접수 및 조사 절차 (피해자 보호 조치 의무 포함)
  4. 가해자 징계 규정 및 재발 방지 대책
  5. CEO의 면책을 위한 관리 감독 의무 명시

  형식: 전문적인 한국어 마크다운. 기업 취업규칙에 바로 붙여넣을 수 있는 법률 문서 형태.`;

  try {
    const response = await getClient().chat.completions.create({
      model: "gpt-4o-mini",
      messages: [{ role: "user", content: prompt }],
    });
    return response.choices[0]?.message?.content || "";
  } catch (error) {
    console.error("OpenAI Rule Generation Error:", error);
    return "법령 데이터를 분석하는 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.";
  }
};

/**
 * 사건 데이터 기반 AI 리스크 분석 시스템 (GPT-4o)
 * 통계적 분석과 유사 사례 데이터를 기반으로 리스크 요인을 평가합니다.
 * 주의: 본 결과는 법률 자문이 아닌 데이터 분석 자료입니다.
 */
export const generateRiskAssessment = async (reportContent: string) => {
  const prompt = `당신은 직장 내 괴롭힘 사건의 데이터 분석 시스템입니다.
다음 접수된 제보 내용을 분석하여 객관적인 리스크 요인 평가 보고서를 작성하세요.

[사건 본문]
"${reportContent}"

[분석 요청 사항]
1. 리스크 수준 평가 (Low/Medium/High/Critical)
   - 유사 사례 통계에 기반한 수치적 평가
   - 판단 근거가 되는 객관적 사실 나열

2. 사실 관계 체크리스트
   - 제보 내용에서 확인 가능한 사실들 (육하원칙)
   - 추가 확인이 필요한 사항들
   - 객관적 증거 유무 체크

3. 유사 사례 통계 참고 데이터
   - 비슷한 유형의 사건 처리 패턴
   - 일반적인 조치 이력 데이터

4. 조직 리스크 요인 분석
   - 현재 상황에서 발생 가능한 리스크 목록
   - 각 리스크의 영향도 수준

---
⚠️ **[중요 안내]**
본 분석 결과는 통계 및 데이터에 기반한 참고 자료이며, **법률적 자문이 아닙니다.**
최종 판단 및 조치는 반드시 **전문 법률가와 상의**하십시오.

형식: 체계적인 한국어 마크다운. 객관적이고 데이터 중심적인 어조 사용.`;

  try {
    const response = await getClient().chat.completions.create({
      model: "gpt-4o",
      messages: [{ role: "user", content: prompt }],
    });
    return response.choices[0]?.message?.content || "";
  } catch (error) {
    console.error("OpenAI Risk Assessment Error:", error);
    return "리스크 분석 시스템에 오류가 발생했습니다. 잠시 후 다시 시도하거나 담당자에게 문의하세요.";
  }
};

/** @deprecated Use generateRiskAssessment instead */
export const getLegalAdvice = generateRiskAssessment;

/**
 * 사건 심각도 및 카테고리 자동 분류 (JSON 출력)
 */
export const triageReport = async (reportContent: string) => {
  try {
    const response = await getClient().chat.completions.create({
      model: "gpt-4o-mini",
      messages: [
        {
          role: "system",
          content: "You are a triage system. Respond only with valid JSON."
        },
        {
          role: "user",
          content: `다음 제보 내용을 분석하여 심각도와 카테고리를 분류하라: "${reportContent}"

응답 형식 (JSON):
{
  "priority": "LOW|MEDIUM|HIGH|CRITICAL",
  "reason": "이 분류를 결정한 이유 (한국어)",
  "category": "Verbal Abuse|Sexual Harassment|Power Abuse|Retaliation|General Complaint"
}`
        }
      ],
      response_format: { type: "json_object" }
    });

    const content = response.choices[0]?.message?.content || "{}";
    return JSON.parse(content);
  } catch (error) {
    console.error("Triage Error:", error);
    return null;
  }
};
