class JapanesePhrase {
  final String category;
  final String japanese;
  final String furigana;
  final String romaji;
  final String english;
  final String contextTip;

  const JapanesePhrase({
    required this.category,
    required this.japanese,
    required this.furigana,
    required this.romaji,
    required this.english,
    this.contextTip = '',
  });
}

class PhraseData {
  static const List<JapanesePhrase> phrases = [
    // --- 1. Train & Transit ---
    JapanesePhrase(
      category: 'Transit',
      japanese: 'この電車は新宿に行きますか？',
      furigana: 'この でんしゃ は しんじゅく に いきますか？',
      romaji: 'Kono densha wa Shinjuku ni ikimasu ka?',
      english: 'Does this train go to Shinjuku?',
      contextTip: 'Show this to a station attendant (駅員さん) on the platform.',
    ),
    JapanesePhrase(
      category: 'Transit',
      japanese: 'Suicaをチャージしたいです。',
      furigana: 'すいか を ちゃーじ したいです。',
      romaji: 'Suica o chaaji shitai desu.',
      english: 'I want to top up my Suica / Pasmo card.',
      contextTip: 'Ticket machines or konbini cash registers.',
    ),
    JapanesePhrase(
      category: 'Transit',
      japanese: '乗り換えはどこですか？',
      furigana: 'のりかえ は どこですか？',
      romaji: 'Norikae wa doko desu ka?',
      english: 'Where is the transfer?',
      contextTip: 'Useful in complex labyrinth stations like Shibuya or Tokyo Station.',
    ),

    // --- 2. Konbini & Shopping ---
    JapanesePhrase(
      category: 'Konbini',
      japanese: '温めてください。',
      furigana: 'あたためてください。',
      romaji: 'Atatamete kudasai.',
      english: 'Please heat this up (microwave lunchbox).',
      contextTip: 'The clerk usually asks: "Atatame masu ka?" Reply with this.',
    ),
    JapanesePhrase(
      category: 'Konbini',
      japanese: '袋は大丈夫です。',
      furigana: 'ふくろ は だいじょうぶ です。',
      romaji: 'Fukuro wa daijoubu desu.',
      english: "I don't need a bag (I have my own).",
      contextTip: 'Polite way to decline plastic shopping bags (paid in Japan).',
    ),
    JapanesePhrase(
      category: 'Konbini',
      japanese: 'これで公共料金を払えますか？',
      furigana: 'これ で こうきょう りょうきん を はらえますか？',
      romaji: 'Kore de koukyou ryoukin o haraemasu ka?',
      english: 'Can I pay this utility bill here?',
      contextTip: 'Hand over your electricity/gas barcoded slip at the cashier.',
    ),

    // --- 3. Ward Office & Administration ---
    JapanesePhrase(
      category: 'Ward Office',
      japanese: '住所変更の手続きをしたいです。',
      furigana: 'じゅうしょ へんこう の てつづき を したいです。',
      romaji: 'Juusho henkou no tetsuduki o shitai desu.',
      english: 'I want to register a change of address.',
      contextTip: 'Must be completed within 14 days of moving into a new ward/city.',
    ),
    JapanesePhrase(
      category: 'Ward Office',
      japanese: '住民票が1通必要です。',
      furigana: 'じゅうみんひょう が いつつ ひつよう です。',
      romaji: 'Juuminhyou ga ittsuu hitsuyou desu.',
      english: 'I need one copy of my Certificate of Residence.',
      contextTip: 'Commonly requested by Japanese landlords, banks, and employers.',
    ),
    JapanesePhrase(
      category: 'Ward Office',
      japanese: '英語を話せるスタッフはいますか？',
      furigana: 'えいご を はなせる すたっふ は いますか？',
      romaji: 'Eigo o hanaseru sutaffu wa imasu ka?',
      english: 'Is there any staff who can speak English?',
      contextTip: 'Major city offices often have a multilingual desk.',
    ),

    // --- 4. Dining & Allergies ---
    JapanesePhrase(
      category: 'Dining',
      japanese: 'これに豚肉は入っていますか？',
      furigana: 'これ に ぶたにく は はいっていますか？',
      romaji: 'Kore ni butaniku wa haitte imasu ka?',
      english: 'Does this contain pork?',
      contextTip: 'Useful for Halal or vegetarian dietary restrictions.',
    ),
    JapanesePhrase(
      category: 'Dining',
      japanese: 'お会計をお願いします。',
      furigana: 'おかいけい を おねがいします。',
      romaji: 'O-kaikei o onegaishimasu.',
      english: 'The bill, please.',
      contextTip: 'Cross your index fingers in an "X" shape as a universal gesture.',
    ),

    // --- 5. Medical & Pharmacy ---
    JapanesePhrase(
      category: 'Medical',
      japanese: '熱と頭痛があります。',
      furigana: 'ねつ と ずつう が あります。',
      romaji: 'Netsu to zutsuu ga arimasu.',
      english: 'I have a fever and a headache.',
      contextTip: 'Say this to reception or doctor when filling medical questionnaires.',
    ),
    JapanesePhrase(
      category: 'Medical',
      japanese: '保険証を持っています。',
      furigana: 'ほけんしょう を もっています。',
      romaji: 'Hokenshou o motte imasu.',
      english: 'I have my Health Insurance card.',
      contextTip: 'Presenting insurance covers 70% of medical costs in Japan.',
    ),

    // --- 6. Garbage & Recycling ---
    JapanesePhrase(
      category: 'Garbage',
      japanese: 'これは何ごみですか？',
      furigana: 'これ は なにごみ ですか？',
      romaji: 'Kore wa nani gomi desu ka?',
      english: 'What kind of garbage is this?',
      contextTip: 'Ask your landlord or neighbors when in doubt.',
    ),
    JapanesePhrase(
      category: 'Garbage',
      japanese: '粗大ごみの回収を申し込みたいです。',
      furigana: 'そだいごみ の かいしゅう を もうしこみたいです。',
      romaji: 'Sodai gomi no kaishuu o moushikomitai desu.',
      english: 'I want to schedule oversized trash pickup.',
      contextTip: 'Items over 30cm (chairs, mattresses) require special paid stickers from konbini.',
    ),
  ];
}
