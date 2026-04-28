(function () {
  // Prioritas config:
  // 1) window.__SUPABASE_URL__ / window.__SUPABASE_ANON_KEY__
  // 2) localStorage SUPABASE_URL / SUPABASE_ANON_KEY
  // 3) hardcoded fallback (isi jika ingin langsung bake-in ke file)
  const HARDCODED_SUPABASE_URL = '';
  const HARDCODED_SUPABASE_ANON_KEY = '';

  const SUPABASE_URL =
    window.__SUPABASE_URL__ ||
    localStorage.getItem('SUPABASE_URL') ||
    HARDCODED_SUPABASE_URL;

  const SUPABASE_ANON_KEY =
    window.__SUPABASE_ANON_KEY__ ||
    localStorage.getItem('SUPABASE_ANON_KEY') ||
    HARDCODED_SUPABASE_ANON_KEY;

  function ensureClient() {
    if (!window.supabase || !window.supabase.createClient) {
      console.warn('[Supabase] sdk belum termuat. Pastikan script CDN supabase-js sudah ditambahkan.');
      return null;
    }
    if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
      console.warn('[Supabase] URL/ANON_KEY belum diatur. Simpan di localStorage: SUPABASE_URL dan SUPABASE_ANON_KEY.');
      return null;
    }
    return window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
  }

  const client = ensureClient();

  window.AppSupabase = {
    client,
    isReady: Boolean(client),
    async requireAuth() {
      if (!client) return { user: null, error: new Error('Supabase client belum siap') };
      const { data, error } = await client.auth.getUser();
      return { user: data?.user || null, error };
    }
  };
})();
