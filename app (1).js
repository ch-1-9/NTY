// Ticker pehle, taaki Supabase ke bina bhi chale
(function(){
  const t = document.querySelector('.ticker div');
  if(t) t.textContent = ONION_CONFIG.ticker.join('   •   ');
})();

let sb = null;
const configured = ONION_CONFIG.supabaseUrl.startsWith('http') && !ONION_CONFIG.supabaseAnonKey.startsWith('YAHAN');
try { if(configured) sb = supabase.createClient(ONION_CONFIG.supabaseUrl, ONION_CONFIG.supabaseAnonKey); } catch(e){ console.error(e); }

async function currentUser(){
  if(!sb) return null;
  const {data} = await sb.auth.getUser();
  return data.user;
}

// Login / Register modal
(function(){
  const modal = document.getElementById('authModal');
  if(!modal) return;
  const title = modal.querySelector('h3'), out = document.getElementById('authMsg');
  let mode = 'login';
  const open = m => {
    mode = m; title.textContent = m==='login' ? 'Login' : 'Register';
    out.className = 'msg err';
    out.textContent = sb ? '' : 'Supabase abhi jodi nahi gayi hai. config.js mein URL aur key daalein (SETUP.md dekhein).';
    modal.classList.add('show');
  };
  document.getElementById('loginBtn').onclick = ()=>open('login');
  document.getElementById('registerBtn').onclick = ()=>open('register');
  document.getElementById('authClose').onclick = ()=>modal.classList.remove('show');
  document.getElementById('authGo').onclick = async ()=>{
    if(!sb) return;
    const email = document.getElementById('authEmail').value.trim();
    const password = document.getElementById('authPass').value;
    const r = mode==='login' ? await sb.auth.signInWithPassword({email,password}) : await sb.auth.signUp({email,password});
    if(r.error){ out.className='msg err'; out.textContent = r.error.message; return; }
    out.className='msg';
    out.textContent = mode==='login' ? 'Login ho gaya' : 'Register ho gaya. Email confirm karna pad sakta hai.';
    setTimeout(()=>{ modal.classList.remove('show'); refreshAuthUI(); }, 800);
  };
  async function refreshAuthUI(){
    const u = await currentUser();
    const box = document.querySelector('.auth');
    if(u){
      box.textContent = '';
      const s = document.createElement('span'); s.textContent = u.email + ' ';
      const b = document.createElement('button'); b.textContent = 'Logout';
      b.onclick = async ()=>{ await sb.auth.signOut(); location.reload(); };
      box.append(s,b);
    }
  }
  refreshAuthUI();
})();
