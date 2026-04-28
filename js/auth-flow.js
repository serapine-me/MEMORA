(function () {
  async function register(payload) {
    const client = window.AppSupabase?.client;
    if (!client) throw new Error('Supabase client belum siap');

    const { data, error } = await client.auth.signUp({
      email: payload.email,
      password: payload.password,
      options: {
        data: {
          full_name: payload.full_name,
          whatsapp_no: payload.whatsapp_no
        }
      }
    });
    if (error) throw error;

    if (data.user) {
      const { error: profileError } = await client
        .from('profiles')
        .upsert({
          id: data.user.id,
          full_name: payload.full_name,
          whatsapp_no: payload.whatsapp_no,
          email: payload.email
        });
      if (profileError) throw profileError;
    }

    return data;
  }

  async function login(payload) {
    const client = window.AppSupabase?.client;
    if (!client) throw new Error('Supabase client belum siap');

    const { data, error } = await client.auth.signInWithPassword({
      email: payload.email,
      password: payload.password
    });
    if (error) throw error;
    return data;
  }

  async function logout() {
    const client = window.AppSupabase?.client;
    if (!client) return;
    await client.auth.signOut();
  }

  window.AuthFlow = { register, login, logout };
})();
