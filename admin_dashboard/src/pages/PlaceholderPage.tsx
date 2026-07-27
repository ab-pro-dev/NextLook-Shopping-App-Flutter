import React from 'react';
import { Clock } from 'lucide-react';

interface PlaceholderProps {
  title: string;
  description?: string;
}

export const PlaceholderPage: React.FC<PlaceholderProps> = ({ title, description }) => {
  return (
    <div className="bg-white p-12 rounded-2xl border border-gray-100 shadow-xs text-center max-w-2xl mx-auto my-8 space-y-4">
      <div className="w-16 h-16 bg-[#6C63FF]/10 text-[#6C63FF] rounded-2xl flex items-center justify-center mx-auto">
        <Clock className="w-8 h-8" />
      </div>
      <h2 className="text-2xl font-bold text-gray-900 m-0">{title}</h2>
      <p className="text-gray-500 text-sm max-w-md mx-auto">
        {description || `The ${title} management module is scheduled for implementation in the next phase step.`}
      </p>
      <div className="pt-4">
        <span className="inline-block bg-[#F5F6FA] text-gray-600 px-4 py-2 rounded-xl text-xs font-semibold border border-gray-200">
          Module Under Active Development
        </span>
      </div>
    </div>
  );
};
