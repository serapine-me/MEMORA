(function () {
  const SUPABASE_URL = window.__SUPABASE_URL__ || localStorage.getItem('https://hhiwxpdzmuzlzprvlanb.supabase.co') || '';
  const SUPABASE_ANON_KEY = window.__SUPABASE_ANON_KEY__ || localStorage.getItem('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhoaXd4cGR6bXV6bHpwcnZsYW5iIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcxMjY2MTEsImV4cCI6MjA5MjcwMjYxMX0.IycRpp8pK2c5zmBeMF15kfy3MS5ZaQmPd2M8WKHB304
                                                                                 ') || '';

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
