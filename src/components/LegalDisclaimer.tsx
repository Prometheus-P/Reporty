import React from 'react';
import { ICONS } from '../constants';

interface LegalDisclaimerProps {
  /** Optional custom text to override default disclaimer */
  customText?: string;
}

const DEFAULT_DISCLAIMER =
  "본 시스템의 분석 결과는 법률적 자문이 아니며, 참고용 데이터 분석 자료입니다. 최종 판단은 법률 전문가와 상의하십시오.";

/**
 * 법적 고지사항 컴포넌트 (Iron Dome Phase 1)
 * 모든 화면 하단에 고정 표시되어 사용자에게 시스템의 법적 한계를 명시합니다.
 */
const LegalDisclaimer: React.FC<LegalDisclaimerProps> = ({ customText }) => {
  const disclaimerText = customText || DEFAULT_DISCLAIMER;

  return (
    <aside
      className="fixed bottom-0 left-0 right-0 z-50 bg-slate-900/95 backdrop-blur-sm border-t border-slate-700 py-3 px-6 print:static print:bg-slate-100 print:border-slate-200"
      role="contentinfo"
      aria-label="법적 고지사항"
    >
      <div className="max-w-7xl mx-auto flex items-center justify-center gap-3">
        <ICONS.AlertOctagon
          className="w-4 h-4 text-amber-400 flex-shrink-0"
          aria-hidden="true"
        />
        <p className="text-xs text-slate-300 text-center leading-relaxed print:text-slate-700">
          <span className="font-bold text-amber-400 mr-1 print:text-amber-600" aria-hidden="true">[법적 고지]</span>
          <span className="sr-only">법적 고지사항: </span>
          {disclaimerText}
        </p>
      </div>
    </aside>
  );
};

export default LegalDisclaimer;
