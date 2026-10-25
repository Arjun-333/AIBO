class JapaneseMedicineItem {
  final String commonNameEn;
  final String genericIngredient;
  final String japaneseBrand;
  final String japaneseKana;
  final String otcClassification; // 'Type 1 (第1類 - Pharmacist required)', 'Type 2 (第2類 - Available anytime)', 'Type 3 (第3類)'
  final String symptoms;
  final String dosageNote;
  final String pharmacistPromptJp; // Exact phrase to show pharmacist

  const JapaneseMedicineItem({
    required this.commonNameEn,
    required this.genericIngredient,
    required this.japaneseBrand,
    required this.japaneseKana,
    required this.otcClassification,
    required this.symptoms,
    required this.dosageNote,
    required this.pharmacistPromptJp,
  });
}

class DrugstoreChainInfo {
  final String nameEn;
  final String nameJa;
  final String features;
  final String logoEmoji;
  final String mapSearchTerm;

  const DrugstoreChainInfo({
    required this.nameEn,
    required this.nameJa,
    required this.features,
    required this.logoEmoji,
    required this.mapSearchTerm,
  });
}

class MedicationService {
  static final MedicationService instance = MedicationService._init();
  MedicationService._init();

  /// Curated directory of foreign medicines and Japanese OTC tablet equivalents
  List<JapaneseMedicineItem> getJapaneseMedicineDirectory() {
    return const [
      JapaneseMedicineItem(
        commonNameEn: 'Paracetamol / Tylenol',
        genericIngredient: 'Acetaminophen (アセトアミノフェン)',
        japaneseBrand: 'Tylenol A (タイレノールA)',
        japaneseKana: 'たいれのーる えー',
        otcClassification: 'Type 2 (第2類 - Available anytime)',
        symptoms: 'Headache, mild fever, toothache (gentle on empty stomach)',
        dosageNote: '1 tablet per dose (300mg). Do not exceed 3 doses/day.',
        pharmacistPromptJp: 'アセトアミノフェン（タイレノールA）を探しています。ありますか？\n(I am looking for acetaminophen / Tylenol A. Do you have it?)',
      ),
      JapaneseMedicineItem(
        commonNameEn: 'Ibuprofen / Advil / Nurofen',
        genericIngredient: 'Ibuprofen (イブプロフェン)',
        japaneseBrand: 'EVE A / EVE Quick (イブA / イブクイック)',
        japaneseKana: 'いぶ えー / いぶ くいっく',
        otcClassification: 'Type 2 (第2類 - Available anytime)',
        symptoms: 'Severe headache, menstrual pain, joint pain, fever',
        dosageNote: '2 tablets per dose with water. Take after meals (食後).',
        pharmacistPromptJp: '頭痛薬の「イブ（EVE）」を探しています。\n(I am looking for the headache medicine EVE.)',
      ),
      JapaneseMedicineItem(
        commonNameEn: 'Strong Painkiller (Loxoprofen)',
        genericIngredient: 'Loxoprofen Sodium (ロキソプロフェンナトリウム)',
        japaneseBrand: 'Loxonin S (ロキソニンS)',
        japaneseKana: 'ろきそにん えす',
        otcClassification: 'Type 1 (第1類 - Pharmacist required on duty)',
        symptoms: 'Intense headache, toothache, acute back pain, fever',
        dosageNote: '1 tablet per dose. Very effective, take with food and water.',
        pharmacistPromptJp: '薬剤師さんはいますか？ロキソニンSを購入したいです。\n(Is a pharmacist on duty? I would like to buy Loxonin S.)',
      ),
      JapaneseMedicineItem(
        commonNameEn: 'Allergy / Hay Fever / Antihistamine',
        genericIngredient: 'Fexofenadine HCl (フェキソフェナジン塩酸塩)',
        japaneseBrand: 'Allegra FX (アレグラFX)',
        japaneseKana: 'あれぐら えふえっくす',
        otcClassification: 'Type 2 (第2類 - Available anytime)',
        symptoms: 'Sneezing, runny nose, cedar pollen hay fever (花粉症 Kafunsho)',
        dosageNote: '1 tablet twice a day (morning & evening before meals). Non-drowsy.',
        pharmacistPromptJp: '花粉症・アレルギー用の「アレグラFX」はどこにありますか？\n(Where is Allegra FX for hay fever / allergies?)',
      ),
      JapaneseMedicineItem(
        commonNameEn: 'Cold & Flu Tablets',
        genericIngredient: 'Acetaminophen, Dextromethorphan, Clemastine',
        japaneseBrand: 'Pabron Gold A (パブロンゴールドA)',
        japaneseKana: 'ぱぶろん ごーるど えー',
        otcClassification: 'Type 2 (第2類 - Available anytime)',
        symptoms: 'Cough, sore throat, runny nose, chills, fever',
        dosageNote: '3 tablets per dose, 3 times a day within 30 min of meals.',
        pharmacistPromptJp: '風邪薬の「パブロンゴールドA錠」を探しています。\n(I am looking for Pabron Gold A cold tablets.)',
      ),
      JapaneseMedicineItem(
        commonNameEn: 'Stomach Acid / Heartburn / Gastritis',
        genericIngredient: 'Famotidine (ファモチジン)',
        japaneseBrand: 'Gaster 10 (ガスター10)',
        japaneseKana: 'がすたー てん',
        otcClassification: 'Type 1 (第1類 - Pharmacist required on duty)',
        symptoms: 'Heartburn, stomach acid, painful indigestion',
        dosageNote: '1 tablet per dose with water. Max 2 tablets in 24 hours.',
        pharmacistPromptJp: '胃痛・胸焼け薬の「ガスター10」はありますか？\n(Do you have Gaster 10 for stomach pain/heartburn?)',
      ),
      JapaneseMedicineItem(
        commonNameEn: 'Herbal Digestive / Hangover Powder & Tablets',
        genericIngredient: 'Cinnamon, Fennel, Gentian, Sodium Bicarbonate',
        japaneseBrand: 'Ohta\'s Isan (太田胃散 A錠剤)',
        japaneseKana: 'おおたいさん えーじょうざい',
        otcClassification: 'Type 2 (第2類 - Available anytime)',
        symptoms: 'Bloating, overeating, hangover (二日酔い), upset stomach',
        dosageNote: '3 tablets per dose after meals. Gentle traditional formula.',
        pharmacistPromptJp: '胃腸薬の「太田胃散（おおたいさん）」はどこですか？\n(Where is the digestive remedy Ohta\'s Isan?)',
      ),
      JapaneseMedicineItem(
        commonNameEn: 'Motion Sickness / Train Nausea',
        genericIngredient: 'Meclizine, Scopolamine',
        japaneseBrand: 'Travelmin (トラベルミン)',
        japaneseKana: 'とらべるみん',
        otcClassification: 'Type 2 (第2類 - Available anytime)',
        symptoms: 'Nausea, dizziness on trains, buses, or boats',
        dosageNote: 'Take 1 tablet 30 minutes before boarding transportation.',
        pharmacistPromptJp: '乗り物酔い止めの「トラベルミン」を探しています。\n(I am looking for Travelmin for motion sickness.)',
      ),
    ];
  }

  /// Popular Japanese Drugstore Chains and How to Locate Them
  List<DrugstoreChainInfo> getJapaneseDrugstoreChains() {
    return const [
      DrugstoreChainInfo(
        nameEn: 'Matsumoto Kiyoshi',
        nameJa: 'マツモトキヨシ (マツキヨ)',
        features: 'Iconic yellow and blue signs. Located outside nearly every major train station. Wide selection of Type 2/3 OTC medicines, painkillers, and English signage.',
        logoEmoji: '💛',
        mapSearchTerm: 'Matsumoto Kiyoshi マツモトキヨシ',
      ),
      DrugstoreChainInfo(
        nameEn: 'Welcia Pharmacy',
        nameJa: 'ウエルシア薬局',
        features: 'Many branches open late or 24/7 with prescription dispensing counters (調剤薬局) and licensed pharmacists on duty for Type 1 OTC drugs (Loxonin, Gaster).',
        logoEmoji: '💙',
        mapSearchTerm: 'Welcia pharmacy ウエルシア薬局',
      ),
      DrugstoreChainInfo(
        nameEn: 'Cocokara Fine',
        nameJa: 'ココカラファイン',
        features: 'Pink and white signboards. Abundant in shopping malls and station plazas. Carries cold remedies, bandages, and daily hygiene products.',
        logoEmoji: '💖',
        mapSearchTerm: 'Cocokara Fine ココカラファイン',
      ),
      DrugstoreChainInfo(
        nameEn: 'Sun Drug',
        nameJa: 'サンドラッグ',
        features: 'Red and white signboards. Known for high discounts on domestic medicines, vitamin supplements, and energy drinks (リポビタンD).',
        logoEmoji: '❤️',
        mapSearchTerm: 'Sun Drug サンドラッグ',
      ),
      DrugstoreChainInfo(
        nameEn: 'Tomod\'s Pharmacy',
        nameJa: 'トモズ (Tomod\'s)',
        features: 'Western-style drugstore layout with dedicated dispensing pharmacies. Staff in central Tokyo (Roppongi, Shinjuku, Ginza) frequently speak English.',
        logoEmoji: '🌿',
        mapSearchTerm: 'Tomods pharmacy トモズ',
      ),
    ];
  }

  /// Essential Japanese phrases to show pharmacists when searching for medication
  List<Map<String, String>> getPharmacistHelpPhrases() {
    return const [
      {
        'title': 'Asking for Pharmacist',
        'jp': '薬剤師（やくざいし）さんはいますか？',
        'romaji': 'Yakuzaishi-san wa imasu ka?',
        'en': 'Is there a licensed pharmacist on duty? (Required for Type 1 drugs)',
      },
      {
        'title': 'Headache / Fever',
        'jp': '頭が痛くて、熱があります。解熱鎮痛剤はありますか？',
        'romaji': 'Atama ga itakute, netsu ga arimasu. Genetsu chintsuuzai wa arimasu ka?',
        'en': 'I have a headache and fever. Do you have pain/fever relief tablets?',
      },
      {
        'title': 'Stomach Pain',
        'jp': '胃がキリキリ痛みます。胃薬（いぐすり）はどこですか？',
        'romaji': 'I ga kirikiri itamimasu. Igusuri wa doko desu ka?',
        'en': 'My stomach hurts sharply. Where are the stomach medicines?',
      },
      {
        'title': 'Allergy / Hay Fever',
        'jp': '花粉症（アレルギー）の錠剤を探しています。眠くならないものがいいです。',
        'romaji': 'Kafunshou no jouzai o sagashite imasu. Nemuku naranai mono ga ii desu.',
        'en': 'I am looking for allergy tablets. Non-drowsy preferred.',
      },
      {
        'title': 'How to Take',
        'jp': 'これは1回に何錠、いつ飲めばいいですか？',
        'romaji': 'Kore wa ikkai ni nan-jou, itsu nomeba ii desu ka?',
        'en': 'How many tablets per dose, and when should I take them?',
      },
    ];
  }
}
