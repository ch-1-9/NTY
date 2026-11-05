// ===== Onion settings =====
const ONION_CONFIG = {
  supabaseUrl: "YAHAN_SUPABASE_URL",
  supabaseAnonKey: "YAHAN_SUPABASE_ANON_KEY",   // anon key public hoti hai, safe hai (RLS rules bachate hain)
  walletAddress: "YAHAN_APNA_BITCOIN_ADDRESS_DAALO",
  ticker: [
    "Onion mein aapka swagat hai",
    "Community se judne ke liye apni details bhariye",
    "Sabhi applications ka status Status page par dekhein"
  ]
};
// Country-wise bitcoin fee code mein nahi, Supabase ki country_fees table mein hoti hai.
