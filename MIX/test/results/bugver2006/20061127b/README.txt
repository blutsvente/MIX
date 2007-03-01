
siehe Zeile 23-59 (denk' Dir die Kommentare weg). Das Problem gilt gleichermaßen für controller_ports_i und controller_ports_o, wobei wir hier als Beispiel nur die controller_ports_i-Mappings anschauen.


Momentanes MIX-Ergebnis:
source/vcth_stby.v: .controller_ports_i[33](tmu_stby_tclkfw_s_io),
source/vcth_stby.v: .controller_ports_i[34](tmu_stby_tmsfw_s_io),
source/vcth_stby.v: .controller_ports_i[35](tmu_stby_tdifw_s_io),
source/vcth_stby.v: .controller_ports_i[36](tmu_stby_tclktv_s_io),
source/vcth_stby.v: .controller_ports_i[37](tmu_stby_tmstv_s_io),
source/vcth_stby.v: .controller_ports_i[38](tmu_stby_tditv_s_io),
source/vcth_stby.v: .controller_ports_i[7:0](tmu_stby_cadc_pin_s_io),
source/vcth_stby.v: .controller_ports_o[0](vcty_stby_cadc_pout_s_io[0]),
source/vcth_stby.v: .controller_ports_o[10](vcty_stby_cadc_pout_s_io[5]),
source/vcth_stby.v: .controller_ports_o[12](vcty_stby_cadc_pout_s_io[6]),
source/vcth_stby.v: .controller_ports_o[14](vcty_stby_cadc_pout_s_io[7]),
source/vcth_stby.v: .controller_ports_o[2](vcty_stby_cadc_pout_s_io[1]),
source/vcth_stby.v: .controller_ports_o[4](vcty_stby_cadc_pout_s_io[2]),
source/vcth_stby.v: .controller_ports_o[64](vcty_stby_tdotv_s_io),
source/vcth_stby.v: .controller_ports_o[65](vcty_stby_tdotv_en_s_io),
source/vcth_stby.v: .controller_ports_o[66](vcty_stby_tdofw_s_io),
source/vcth_stby.v: .controller_ports_o[67](vcty_stby_tdofw_en_s_io),
source/vcth_stby.v: .controller_ports_o[6](vcty_stby_cadc_pout_s_io[3]),
source/vcth_stby.v: .controller_ports_o[8](vcty_stby_cadc_pout_s_io[4]),
source/vcth_stby.v: .mbist_tbi[22:0](mix_const_10), {vgch.0001.herberg}:mix > 


Sollte aber sein:
.controller_ports_i({vcty_stby_tdofw_en_s_io, vcty_stby_tdofw_s_io, ..., vcty_stby_cadc_pout_s_io[0]),

wobei alle Bit-Zuordnungen sortiert werden müssen und Lücken mit Low belegt.

Gruß,
Philipp
