# Onion setup

1. supabase.com par free project banao.
2. SQL Editor mein `supabase_setup.sql` poora paste karke Run karo.
3. Authentication > Users > Add user: apna admin email + lamba strong password (kam se kam 14 akshar).
   Is password ko kisi ko mat batana aur kisi file mein mat likhna.
4. Us user ka UUID copy karke SQL Editor mein chalao:
   `insert into admins values ('UUID_YAHAN');`
5. Project Settings > API se URL aur anon key `config.js` mein daalo.
   (anon key public hoti hai; asli suraksha database ke RLS rules se hoti hai. `service_role` key kabhi site mein mat daalna.)
6. Authentication > Providers > Email mein "Confirm email" on rakho.
7. `walletAddress` apna asli bitcoin address daalo.
8. `terms.html` mein [ ] wale hisse bharo.
9. Vercel ya Netlify par folder upload karo, apna domain jodo (HTTPS apne aap lagta hai).
10. Admin panel: `tumhara-domain/admin.html`.
11. Country-wise fee: Supabase Table Editor > `country_fees` mein country aur btc daalo.
