(function () {
  const STORAGE_URL_KEY = 'SUPABASE_URL';
  const STORAGE_ANON_KEY = 'SUPABASE_ANON_KEY';

  // Prioritas config:
  // 1) window.__SUPABASE_URL__ / window.__SUPABASE_ANON_KEY__
  // 2) localStorage SUPABASE_URL / SUPABASE_ANON_KEY
  // 3) hardcoded fallback (isi jika ingin langsung bake-in ke file)
  const HARDCODED_SUPABASE_URL = '';
  const HARDCODED_SUPABASE_ANON_KEY = '';

  function getQueryConfig() {
    const params = new URLSearchParams(window.location.search);
    const url = params.get('supabase_url') || '';
    const key = params.get('supabase_anon_key') || '';
    return { url, key };
  }

  function getMetaConfig() {
    const urlMeta = document.querySelector('meta[name=\"supabase-url\"]');
    const keyMeta = document.querySelector('meta[name=\"supabase-anon-key\"]');
    return {
      url: urlMeta?.content || '',
      key: keyMeta?.content || ''
    };
  }

  const queryCfg = getQueryConfig();
  const metaCfg = getMetaConfig();

  if (queryCfg.url && queryCfg.key) {
    localStorage.setItem(STORAGE_URL_KEY, queryCfg.url);
    localStorage.setItem(STORAGE_ANON_KEY, queryCfg.key);
  }

  const SUPABASE_URL =
    window.__SUPABASE_URL__ ||
    localStorage.getItem(STORAGE_URL_KEY) ||
    metaCfg.url ||
    queryCfg.url ||
    HARDCODED_SUPABASE_URL;

  const SUPABASE_ANON_KEY =
    window.__SUPABASE_ANON_KEY__ ||
    localStorage.getItem(STORAGE_ANON_KEY) ||
    metaCfg.key ||
    queryCfg.key ||
    HARDCODED_SUPABASE_ANON_KEY;

  function ensureClient() {
    if (!window.supabase || !window.supabase.createClient) {
      console.warn('[Supabase] sdk belum termuat. Pastikan script CDN supabase-js sudah ditambahkan.');
      return null;
    }
    if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
      console.warn('[Supabase] URL/ANON_KEY belum diatur. Simpan via localStorage / query params / meta tag.');
      return null;
    }
    return window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
  }

  const client = ensureClient();

  window.AppSupabase = {
    client,
    isReady: Boolean(client),
    config: {
      url: SUPABASE_URL ? `${SUPABASE_URL.slice(0, 28)}...` : '',
      hasAnonKey: Boolean(SUPABASE_ANON_KEY)
    },
    configure({ url, anonKey }) {
      if (!url || !anonKey) throw new Error('url dan anonKey wajib diisi');
      localStorage.setItem(STORAGE_URL_KEY, url.trim());
      localStorage.setItem(STORAGE_ANON_KEY, anonKey.trim());
      window.location.reload();
    },
    async requireAuth() {
      if (!client) return { user: null, error: new Error('Supabase client belum siap') };
      const { data, error } = await client.auth.getUser();
      return { user: data?.user || null, error };
    }
  };
})();
