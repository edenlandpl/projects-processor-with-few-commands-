link l1:ct
link l2:rdm
link rb: 8,9,10,z
 
equ ax: r0
equ cx: r1
equ dx: r2
equ bx: r3
equ sp: r4
equ bp: r5
equ si: r6
equ ddi: r7
equ cs: r8
equ ss: r9
equ ds: r10
equ ip: r12
equ es: r11
 
equ pom1: r13
equ pom2: r14
equ rr: r15
 
accept cx:0003h
accept ax:0000h
accept bx:0000h
accept dx:0000h
accept cs:789Ah
accept ip:FFFEh
accept ss:0002h
accept sp:0001h
\\ w dx powinno byc 8 na koniec
dw 8899Eh:4300h,5900h,2500h,0000h,4000h,4000,5000h,5900h,4200h,E2FFh,5900h,E2F6h
\\    x:  incbx pushcx andax0 incax,incax,pushax,popcx,incdx, loopodejmij1,popcx, loopodejmij10
dw 0020h:FFFFh,AAAAh,0001h
 
macro fl:{load rm, flags;}
macro dec reg:{sub reg,reg,z,z;fl;}
macro inc reg:{add reg,reg,1,z;fl;}
macro mov reg1, reg2:{OR reg1, reg2,z;}
 
odczyt_rozkazu
{mov pom1,cs;}
{mov rq,ip;}
{cjs nz,obadrfiz;}
{and nil,pom1,pom1;oey;ewl;}
{and nil, pom2,pom2;oey;ewh;}
{R;mov rr,bus_d; cjp rdm,cp;}

{and rq,rr,F800h;}
\\F8
{xor nil, rq, 4000h;fl;}
{cjp RM_z, roz_inc;}

{xor nil, rq, 5000h;fl;}
{cjp RM_z, roz_push;}
\\FF
{and rq,rr,FF00h;}

{xor nil, rq, 2500h;fl;}
{cjp RM_z, roz_and;}
\\F8
{and rq,rr,F800h;}

{xor nil, rq, 4800h;fl;}
{cjp RM_z, roz_dec;}
{xor nil, rq, 9000h;fl;}
{cjp RM_z, roz_xchg;}

{xor nil, rq, 5800h;fl;}
{cjp RM_z, roz_pop;}
 
{and rq,rr,FF00h;}
{xor nil, rq, E200h;fl;}
{cjp RM_z, roz_loop;}
{xor nil, rq, 6A00h;fl;}
{cjp RM_z, roz_nop;}
 
 
 
wroc
{end;}
 
roz_nop
{jmap zapis_powrotny;}

roz_and
{mov rq, rr;}
{and rr, 800h;}
{xor rr, 800h;fl;} \\ sprawdza W, jesli jest 1, w naszym jest, to xor daje 1. jesli w=0 xor da 0;
{cjp RM_Z, add2;}
{and rq, 00FFh;}
{and ax, rq;fl;}
{jmap zapis_powrotny;}
 
add2 \\ przejdzie tutaj,bo w=1
{cjs nz, odczyt_komorki;}
{mov pom2, rr;} \\ little endian -> zamiana mlodsze bity jako starsze i na odwrot
{push nz, 7;} \\ przesuniecie
{sll pom2;}
{srl rr;}
{rfct;}
{add pom2, rr;}
{and ax, pom2;fl;} \\ logiczne dodawanie
{jmap zapis_powrotny;}


odczyt_komorki
{add ip,ip,1,z;fl;}
{cjp rm_z,modyf_cs;}
{mov pom1,cs;}
{mov rq,ip;}
{cjs nz,obadrfiz;}
{and nil,pom1,pom1;oey;ewl;}
{and nil, pom2,pom2;oey;ewh;}
{R;mov rr,bus_d; cjp rdm,cp;}
{crtn nz;}

ip_skok
{mov rq, pom2;}
{and nil, rr, 0080h;fl;}
{cjp RM_Z, ip_dodaj;}
 
ip_minus
{and rq, rr, 00FFh;}
{or rq, rq, FF00h;}
{add ip, rq;fl;}
{cjp not RM_V, odczyt_rozkazu;}
{sub cs, 1000h, nz;}
{jmap odczyt_rozkazu;}
 
ip_dodaj
{and rq, rr, 00FFh;}
{add ip, rq; fl;}
{cjp not RM_C, odczyt_rozkazu;}
{add cs, 1000h;}
{jmap odczyt_rozkazu;}
 
roz_loop
{dec cx;}
{xor rq, cx, 0000h;fl;}
{mov rq, rr;}
{cjp not RM_Z, ip_skok;}
{jmap zapis_powrotny;}
 
roz_jcxz
{mov pom2, rq;}
{mov rq, rb;}
{xor rq, rq, 0000h;fl;}
{cjp RM_Z, ip_skok;}
 
roz_pop
{mov pom1,ss;}
{mov rq,sp;}
{cjs nz,obadrfiz;}
{and nil,pom1,pom1;oey;ewl;}
{and nil, pom2,pom2;oey;ewh;}
{R;mov pom2,bus_d; cjp rdm,cp;}
{mov rq, rr;}
{mov nil, rq; ewb;oey;}
{mov rq, pom2;}
{mov rb, rq;}
{dec sp;}
{jmap zapis_powrotny;}
 
roz_push
{inc sp;}
{mov pom1,ss;}
{mov rq,sp;}
{cjs nz,obadrfiz;}
{and nil,pom1,pom1;oey;ewl;}
{and nil, pom2,pom2;oey;ewh;}
{mov rq, rr;}
{mov nil, rq; ewb;oey;}
{mov rq, rb;}
{W;mov nil,rq;OEY;}
{jmap zapis_powrotny;}
 
roz_dec
{load rm, rn;}
{mov rq, rr;}
{mov nil, rq; ewb;oey;}
{mov rq, rb;}
{dec rq;fl;cem_c;}
{mov rb, rq;}
{load rn,rm;}
{JMAP zapis_powrotny;}
 
roz_inc
{load rm, rn;}
{mov rq, rr;}
{mov nil, rq; ewb;oey;}
{mov rq, rb;}
{inc rq;fl;cem_c;}
{mov rb, rq;}
{load rn,rm;}
{JMAP zapis_powrotny;}
 
roz_xchg
{mov nil, rr; ewb;oey;}
{mov rq, rb;}
{mov pom1, rq;}
{mov rq, ax;}
{mov ax,pom1;}
{mov rb, rq;}
{jmap zapis_powrotny;}
 
zapis_powrotny
{add ip,ip,1,z;fl;}
{cjp rm_z,modyf_cs;}
{jmap odczyt_rozkazu;}
modyf_cs
{add cs,cs,1000h,z;}
{jmap odczyt_rozkazu;}
 
 
obadrfiz
{load rm,z;}
{add pom2, pom2, z;}
 
{push nz, 3;}
 
{sll pom1;}
{sl.25 pom2;}
 
{rfct;}
 
{add pom1, pom1, rq, z; fl;}
{add pom2, pom2, z, rm_c;}
{load rm,z;}
{crtn nz;}