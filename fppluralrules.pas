// http://www.unicode.org/cldr/cldr-aux/charts/22/supplemental/language_plural_rules.html
unit fppluralrules;

{$mode ObjFPC}{$H+}

interface

  uses
    StrUtils, Math;

  const
    PR_ZERO = 'zero';
    PR_ONE = 'one';
    PR_TWO = 'two';
    PR_FEW = 'few';
    PR_MANY = 'many';
    PR_OTHER = 'other';

  function PluralRule(ALocaleCode: String; ADigit: Integer): String; overload;
  function PluralRule(ALocaleCode: String; ADigit: Int64): String; overload;
  function PluralRule(ALocaleCode: String; ADigit: Double): String;

implementation

function PluralRule(ALocaleCode: String; ADigit: Integer): String;
begin
  Result := PluralRule(ALocaleCode, Int64(ADigit));
end;

function PluralRule(ALocaleCode: String; ADigit: Int64): String;
begin

  // default - other
  Result := PR_OTHER;

  // one → n is 1;
  // other → everything else
  if MatchStr(ALocaleCode, [
    'af', 'sq', 'ast', 'asa', 'eu', 'bem', 'bez', 'bn', 'brx', 'bg', 'ca', 'chr', 'cgg', 'da', 'dv', 'nl',
    'en', 'eo', 'et', 'ee', 'fo', 'fi', 'fur', 'gl', 'lg', 'de', 'el', 'gu', 'ha', 'haw', 'is', 'it',
    'kaj', 'kkj', 'kl', 'ks', 'kk', 'ky', 'ku', 'lb', 'jmc', 'ml', 'mr', 'mas', 'mgo', 'mn', 'nah', 'ne', 'nnh',
    'jgo', 'nd', 'no', 'nb', 'nn', 'ny', 'nyn', 'or', 'om', 'os', 'pap', 'ps', 'pt', 'pa', 'rm', 'rof', 'rwk',
    'ssy', 'saq', 'seh', 'ksb', 'sn', 'xog', 'so', 'ckb', 'nr', 'st', 'es', 'sw', 'ss', 'sv', 'gsw', 'syr',
    'ta', 'te', 'teo', 'tig', 'ts', 'tn', 'tk', 'kcg', 'ur', 've', 'vo', 'vun', 'wae', 'fy', 'xh', 'zu']) then
  begin
    if ADigit = 1 then
      Result := PR_ONE
    else
      Result := PR_OTHER;
  end;

  // one → n in 0..1;
  // other → everything else
  if MatchStr(ALocaleCode, ['ak', 'am', 'bh', 'fil', 'guw', 'hi', 'ln', 'mg', 'nso', 'tl', 'ti', 'wa']) then
  begin
    if ADigit in [0..1] then
      Result := PR_ONE
    else
      Result := PR_OTHER;
  end;

  // other → everything
  if MatchStr(ALocaleCode, [
    'az', 'bm', 'my', 'zh', 'dz', 'ka', 'hu', 'ig', 'id', 'ja', 'jv', 'kea', 'kn', 'km', 'ko', 'ses', 'lo',
    'kde', 'ms', 'fa', 'root', 'sah', 'sg', 'ii', 'th', 'bo', 'to', 'tr', 'vi', 'wo', 'yo']) then
  begin;
    Result := PR_OTHER;
  end;

  // one → n is 1;
  // two → n is 2;
  // other → everything else
  if MatchStr(ALocaleCode, ['kw', 'smn', 'iu', 'smj', 'naq', 'se', 'smi', 'sms', 'sma']) then
  begin
    if ADigit = 1 then
      Result := PR_ONE
    else if ADigit = 2 then
      Result := PR_TWO
    else
      Result := PR_OTHER;
  end;

  // one → n mod 10 is 1 and n mod 100 is not 11;
  // few → n mod 10 in 2..4 and n mod 100 not in 12..14;
  // many → n mod 10 is 0 or n mod 10 in 5..9 or n mod 100 in 11..14;
  // other → everything else

  if MatchStr(ALocaleCode, ['be', 'bs', 'hr', 'ru', 'sr', 'sh', 'uk']) then
  begin
    if (ADigit mod 10 = 1) and not (ADigit mod 100 = 11) then
      Result := PR_ONE
    else if (ADigit mod 10 in [2..4]) and not (ADigit mod 100 in [12..14]) then
      Result := PR_FEW
    else if (ADigit mod 10 = 0) or (ADigit mod 10 in [5..9]) or (ADigit mod 100 in [11..14]) then
      Result := PR_MANY
    else
      Result := PR_OTHER;
  end;

  // one → n within 0..2 and n is not 2;
  // other → everything else
  // essentially it's rule #2 for integers, but we leave it separately for easier reading
  if MatchStr(ALocaleCode, ['fr', 'ff', 'kab']) then
  begin
    if (ADigit in [0..2]) and not (ADigit = 2) then
      Result := PR_ONE
    else
      Result := PR_OTHER;
  end;

  // one → n is 1;
  // few → n in 2..4;
  // other → everything else
  if MatchStr(ALocaleCode, ['cs', 'sk']) then
  begin
    if ADigit = 1 then
      Result := PR_ONE
    else if ADigit in [2..4] then
      Result := PR_FEW
    else
      Result := PR_OTHER;
  end;

  // one → n is 1;
  // few → n is 0 OR n is not 1 AND n mod 100 in 1..19;
  // other → everything else
  if MatchStr(ALocaleCode, ['mo', 'ro']) then
  begin
    if ADigit = 1 then
      Result := PR_ONE
    else if (ADigit = 0) or (ADigit mod 100 in [1..19]) then
      Result := PR_FEW
    else
      Result := PR_OTHER;
  end;

  // zero → n is 0;
  // one → n is 1;
  // two → n is 2;
  // few → n mod 100 in 3..10;
  // many → n mod 100 in 11..99;
  // other → everything else
  if ALocaleCode = 'ar' then
  begin
    if ADigit = 0 then
      Result := PR_ZERO
    else if ADigit = 1 then
      Result := PR_ONE
    else if ADigit = 2 then
      Result := PR_TWO
    else if (ADigit mod 100 in [3..10]) then
      Result := PR_FEW
    else if (ADigit mod 100 in [11..99]) then
      Result := PR_MANY
    else
      Result := PR_OTHER;
  end;

  // one → n mod 10 is 1 and n mod 100 not in 11,71,91;
  // two → n mod 10 is 2 and n mod 100 not in 12,72,92;
  // few → n mod 10 in 3..4,9 and n mod 100 not in 10..19,70..79,90..99;
  // many → n is not 0 and n mod 1000000 is 0;
  // other → everything else
  if ALocaleCode = 'br' then
  begin
    if (ADigit mod 10 = 1) and not (ADigit mod 100 in [11, 71, 91]) then
      Result := PR_ONE
    else if (ADigit mod 10 = 2) and not (ADigit mod 100 in [12, 72, 92]) then
      Result := PR_TWO
    else if (ADigit mod 10 in [3..4, 9]) and not (ADigit mod 100 in [10..19, 70..79, 90..99]) then
      Result := PR_FEW
    else if (ADigit <> 0) and (ADigit mod 1000000 = 0) then
      Result := PR_MANY
    else
      Result := PR_OTHER;
  end;

 // one → n in 0..1 or n in 11..99;
 // other → everything else
  if ALocaleCode = 'tzm' then
  begin
    if (ADigit in [0..1]) or (ADigit in [11..99]) then
      Result := PR_ONE
    else
      Result := PR_OTHER;
  end;

 // zero → n is 0;
 // one → n is 1;
 // other → everything else
  if ALocaleCode = 'ksh' then
  begin
    if ADigit = 0 then
      Result := PR_ZERO
    else if ADigit = 1 then
      Result := PR_ONE
    else
      Result := PR_OTHER;
  end;

  // one → n is 1;
  // two → n is 2;
  // many → n is not 0 AND n mod 10 is 0;
  // other → everything else
  if ALocaleCode = 'he' then
  begin
    if ADigit = 1 then
      Result := PR_ONE
    else if ADigit = 2 then
      Result := PR_TWO
    else if (ADigit <> 0) and (ADigit mod 10 = 0) then
      Result := PR_MANY
    else
      Result := PR_OTHER;
  end;

  // one → n is 1;
  // two → n is 2;
  // few → n in 3..6;
  // many → n in 7..10;
  // other → everything else
  if ALocaleCode = 'ga' then
  begin
    if ADigit = 1 then
      Result := PR_ONE
    else if ADigit = 2 then
      Result := PR_TWO
    else if ADigit in [3..6] then
      Result := PR_FEW
    else if ADigit in [7..10] then
      Result := PR_MANY
    else
      Result := PR_OTHER;
  end;

  // zero → n is 0;
  // one → n within 0..2 and n is not 0 and n is not 2; // just n = 1 for integer
  // other → everything else
  if ALocaleCode = 'lag' then
  begin
    if ADigit = 0 then
      Result := PR_ZERO
    else if (ADigit in [0..2]) and (ADigit <> 0) and (ADigit <> 2) then
      Result := PR_ONE
    else
      Result := PR_OTHER;
  end;

  // zero → n is 0;
  // one → n mod 10 is 1 and n mod 100 is not 11;
  // other → everything else
  if ALocaleCode = 'lv' then
  begin
    if ADigit = 0 then
      Result := PR_ZERO
    else if (ADigit mod 10 = 1) and (ADigit mod 100 <> 11) then
      Result := PR_ONE
    else
      Result := PR_OTHER;
  end;

  // one → n mod 10 is 1 and n mod 100 not in 11..19;
  // few → n mod 10 in 2..9 and n mod 100 not in 11..19;
  // other → everything else
  if ALocaleCode = 'lt' then
  begin
    if (ADigit mod 10 = 1) and not (ADigit mod 100 in [11..19]) then
      Result := PR_ONE
    else if (ADigit mod 10 in [2..9]) and not (ADigit mod 100 in [11..19]) then
      Result := PR_FEW
    else
      Result := PR_OTHER;
  end;

  // one → n mod 10 is 1 and n is not 11;
  // other → everything else
  if ALocaleCode = 'mk' then
  begin
    if (ADigit mod 10 = 1) and (ADigit <> 11) then
      Result := PR_ONE
    else
      Result := PR_OTHER;
  end;

  // one → n is 1;
  // few → n is 0 or n mod 100 in 2..10;
  // many → n mod 100 in 11..19;
  // other → everything else
  if ALocaleCode = 'mt' then
  begin
    if ADigit = 1 then
      Result := PR_ONE
    else if (ADigit = 0) or (ADigit mod 100 in [2..10]) then
      Result := PR_FEW
    else if (ADigit mod 100 in [11..19]) then
      Result := PR_MANY
    else
      Result := PR_OTHER;
  end;

  // one → n mod 10 in 1..2 or n mod 20 is 0;
  // other → everything else
  if ALocaleCode = 'gv' then
  begin
    if (ADigit mod 10 in [1..2]) or (ADigit mod 20 = 0) then
      Result := PR_ONE
    else
      Result := PR_OTHER;
  end;

  // one → n is 1;
  // few → n mod 10 in 2..4 and n mod 100 not in 12..14;
  // many → n is not 1 and n mod 10 in 0..1 or n mod 10 in 5..9 or n mod 100 in 12..14;
  // other → everything else
  if ALocaleCode = 'pl' then
  begin
    if ADigit = 1 then
      Result := PR_ONE
    else if (ADigit mod 10 in [2..4]) and not (ADigit mod 100 in [12..14]) then
      Result := PR_FEW
    else if (ADigit mod 10 in [0..1]) or (ADigit mod 10 in [5..9]) or (ADigit mod 100 in [12..14]) then
      Result := PR_MANY
    else
      Result := PR_OTHER;
  end;

  // one → n in 1,11;
  // two → n in 2,12;
  // few → n in 3..10,13..19;
  // other → everything else
  if ALocaleCode = 'gd' then
  begin
    if ADigit in [1, 11] then
      Result := PR_ONE
    else if ADigit in [2, 22] then
      Result := PR_TWO
    else if ADigit in [3..10, 13..19] then
      Result := PR_FEW
    else
      Result := PR_OTHER;
  end;

  // one → n mod 100 is 1;
  // two → n mod 100 is 2;
  // few → n mod 100 in 3..4;
  // other → everything else
  if ALocaleCode = 'sl' then
  begin
    if ADigit mod 100 = 1 then
      Result := PR_ONE
    else if ADigit mod 100 = 2 then
      Result := PR_TWO
    else if ADigit mod 100 in [3..4] then
      Result := PR_FEW
    else
      Result := PR_OTHER;
  end;

  // one → n within 0..1;
  // few → n in 2..10;
  // other → everything else
  if ALocaleCode = 'shi' then
  begin
    if ADigit in [0..1] then
      Result := PR_ONE
    else if ADigit in [2..10] then
      Result := PR_FEW
    else
      Result := PR_OTHER;
  end;

  // zero → n is 0;
  // one → n is 1;
  // two → n is 2;
  // few → n is 3;
  // many → n is 6;
  // other → everything else
  if ALocaleCode = 'cy' then
  begin
    if ADigit = 0 then
      Result := PR_ZERO
    else if ADigit = 1 then
      Result := PR_ONE
    else if ADigit = 2 then
      Result := PR_TWO
    else if ADigit = 3 then
      Result := PR_FEW
    else if ADigit = 6 then
      Result := PR_MANY
    else
      Result := PR_OTHER;
  end;

end;

function PluralRule(ALocaleCode: String; ADigit: Double): String;
begin

  if IsZero (Frac(ADigit)) then
    Exit (PluralRule(ALocaleCode, Trunc(ADigit)));

  if MatchStr(ALocaleCode, [
    'af', 'sq', 'ast', 'asa', 'eu', 'bem', 'bez', 'bn', 'brx', 'bg', 'ca', 'chr', 'cgg', 'da', 'dv', 'nl',
    'en', 'eo', 'et', 'ee', 'fo', 'fi', 'fur', 'gl', 'lg', 'de', 'el', 'gu', 'ha', 'haw', 'is', 'it',
    'kaj', 'kkj', 'kl', 'ks', 'kk', 'ky', 'ku', 'lb', 'jmc', 'ml', 'mr', 'mas', 'mgo', 'mn', 'nah', 'ne', 'nnh',
    'jgo', 'nd', 'no', 'nb', 'nn', 'ny', 'nyn', 'or', 'om', 'os', 'pap', 'ps', 'pt', 'pa', 'rm', 'rof', 'rwk',
    'ssy', 'saq', 'seh', 'ksb', 'sn', 'xog', 'so', 'ckb', 'nr', 'st', 'es', 'sw', 'ss', 'sv', 'gsw', 'syr',
    'ta', 'te', 'teo', 'tig', 'ts', 'tn', 'tk', 'kcg', 'ur', 've', 'vo', 'vun', 'wae', 'fy', 'xh', 'zu',
    'ak', 'am', 'bh', 'fil', 'guw', 'hi', 'ln', 'mg', 'nso', 'tl', 'ti', 'wa','ar', 'az', 'bm', 'my',
    'zh', 'dz', 'ka', 'hu', 'ig', 'id', 'ja', 'jv', 'kea', 'kn', 'km', 'ko', 'ses', 'lo', 'kde', 'ms',
    'fa', 'root', 'sah', 'sg', 'ii', 'th', 'bo', 'to', 'tr', 'vi', 'wo', 'yo', 'be', 'bs', 'hr', 'ru',
    'sr', 'sh', 'uk', 'br', 'tzm', 'ksh', 'kw', 'smn', 'iu', 'smj', 'naq', 'se', 'smi', 'sms', 'sma',
    'cs', 'sk', 'he', 'ga', 'lv', 'lt', 'mk', 'mt', 'gv', 'mo', 'ro', 'pl', 'gd', 'sl', 'cy']) then
  begin
    Result := PR_OTHER;
  end;

  if MatchStr(ALocaleCode, ['fr', 'ff', 'kab', 'lag']) then
  begin
    if (InRange(ADigit, 0, 2)) then
      Result := PR_ONE
    else
      Result := PR_OTHER;
  end;

  if ALocaleCode = 	'shi' then
  begin
    if InRange(ADigit, 0, 1) then
      Result := PR_ONE
    else
      Result := PR_OTHER;
  end;

end;

end.
