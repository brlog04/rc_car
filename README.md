# rc_car
**ANDROID**
- slanje podataka o brzini levog i desnog motora vrednosti brzine od -100 do +100 id,l_speed,r_speed
- citanje podataka jacina signaka i napon napajanja
- provera konekcije (ukoliko odredjeno vreme nema konekcije gase se motori)
- prikaz napona, jacine signala, levi motor brzina, desni motor brzina
- on / off dugme kada je off daljinski je iskljucen tj brzine su nula
- vracanje klizaca na nulu kada se otpusti klizac
- vibro upozorenje na slab signal ili na slabu bateriju
- TODO zadavanje ofseta

  getBroadcastAddress
    - cita svoju IP adresu i postavlja remote na x.x.x.255 (zadnji oktet menja u 255)
  setup
    - pali senzore, postavlja IP adresu, pocinje UDP
  onAccelerometerEvent
    - osluskuje akcelerometar i upravlja levo desno
  mouseDragged
    - osluskuje povlacenje i upravlja brzinom
  mousePressed
    - definise offsete, kontrolise expert mode, zakljucava akcije
  lockRemoteIp
    - zakljucava dobijenu adresu
  receive
    - prima podatke o naponu i jacini signala , resetuje brojac koji broji javljanja rst_count 
  draw
    - crta ekran
    - proverava rst_count i ako je veci od 200 javlja da nema konekcije
    - ako je IP zakljucan otkljucava i zove getBroadcastAddress
    - racuna l_speed i r_speed
    - povecava vib_count i ako je vcc<35 i vib_count<5 vibrira - upozorava na mali napon
    - salje UDP poruku

 
**ESP**
- prima podatke o brzini motora i salje na driver
- salje podatke o naponu i jacini signala
- setup -
  - postavlja pinove na output rezim,
  - pali status diodu,
  - zapocinje konektovanje sa blinkanjem diode,
  - postavlja remote ip zadnji oktet na 255,
  - zapocinje UDP konekciju
    
- loop
  - ako je konekcija ostvarena gasi diodu
    - cita paket
    - salje vrednosti na drivere ako je dobar ID uredjaja pogodjen
    - na svakih 1500ms salje podatke o naponu i jacini signala
    - ako za 900ms nije stigao podatak sa telefona gasi motore
  - ako nema konekcije treperi diodu u odnosu 60/1000 i ugasi motore
