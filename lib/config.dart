const int user_id = 0;
const String user_data_url = ""; // Configure your firebase realtime database and add the url here to use the database feature!


// the days after which a product date of a product without an estimated shelf live will have a red date on "My Fridge" 
const int defaultDeltaDaysDanger = 12; 
// the day count before the expiration on which  a product will have a yellow date on "My Fridge" 
const int warningDaysBeforeProductExpiration = 2;



// not for every category is a value provided!

// = "Mindesthaltbarkeitstage" 
// per main category 
const Map<String, int> estimatedMaincatShelfLifeDays = {
  "Milchprodukte" : 5,
  "Eier": 14,

  "Fleisch, Fisch": 2,
  "Früchte, Obst": 3,
  "Gemüse": 3,
  "Getränke, Alkohol": 3,
  "Sojaprodukte": 4,
};

// = "Mindesthaltbarkeitstage" 
// per sub category 
const Map<String, int> estimatedSubcatShelfLifeDays = {
  "Honig" : 730, // 2 years
  "Konfitüren": 14,
  "Marmeladen": 14,

  "Fischkonserven": 548, // 18 months
  "Fleischkonserven": 548, // 18 months 
  "Obstkonserven": 548, // 18 months 
  "Essigkonserven": 548, // 18 months
  "Gemüsekonserven": 548, // 18 months  

  "Pudding": 3,
  "Speiseeis": 182, // 6 months

  "Kekse": 28,
  "Bonbons": 3650, // 10 years
  "Chips": 182, // 6 months
  "Fruchtgummi": 3650, // 10 years
  "Schokoriegel": 3650, // 10 years
  "Kaugummi": 3650, // 10 years
  "Schokolade": 3650, // 10 years
  "salzige Snacks": 182, // 6 months
};

