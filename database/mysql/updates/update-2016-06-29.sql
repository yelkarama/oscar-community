ALTER TABLE LookupList ADD COLUMN `listTitle` varchar(255) AFTER `id`;

REPLACE into encounterForm values ('Gynae Form', '../form/formgynae.jsp?demographic_no=', 'formgyane', '0');

CREATE TABLE IF NOT EXISTS  `formgyane` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `visitDate` date,
  `demographic_no` int(11),
  `comments` text,
  `fromDate` date,
  `toDate` date,
  `bpi_age` varchar(5),
  `bpi_g` varchar(20),
  `bpi_t` varchar(20),
  `bpi_p` varchar(20),
  `bpi_a` varchar(20),
  `bpi_l` varchar(20),
  `bpi_minlength` varchar(5),
  `bpi_maxlength` varchar(5),
  `bpi_mininterval` varchar(5),
  `bpi_maxinterval` varchar(5),
  `bpi_amountpads` varchar(5),
  `bpi_current_contra_method` varchar(10),
  `bpi_lmp_n` tinyint(1),
  `bpi_lmp_abn` tinyint(1),
  `bpi_lastpap_n` tinyint(1),
  `bpi_lastpap_abn` tinyint(1),
  `bpi_lastmemo_n` tinyint(1),
  `bpi_lastmemo_abn` tinyint(1),
  `obs_svd` varchar(10),
  `obs_cs` varchar(10),
  `obs_notes` text,
  `fmh_brest` tinyint(1),
  `fmh_gynaecological` tinyint(1),
  `fmh_bowel` tinyint(1),
  `fmh_osteoporosis` tinyint(1),
  `fmh_notes` text,
  `pmh_wt_loss` tinyint(1),
  `pmh_tuberculosis` tinyint(1),
  `pmh_urinary` tinyint(1),
  `pmh_diabetes` tinyint(1),
  `pmh_headaches` tinyint(1),
  `pmh_jaundice_hep` tinyint(1),
  `pmh_anemia_blood` tinyint(1),
  `pmh_cancer` tinyint(1),
  `pmh_heart_disease` tinyint(1),
  `pmh_gall_bladder` tinyint(1),
  `pmh_blood_trans` tinyint(1),
  `pmh_epilepsy` tinyint(1),
  `pmh_hypertension` tinyint(1),
  `pmh_hernia_ulser` tinyint(1),
  `pmh_varicose` tinyint(1),
  `pmh_arthritis` tinyint(1),
  `pmh_respiratory` tinyint(1),
  `pmh_bowel_disorder` tinyint(1),
  `pmh_phlebitis` tinyint(1),
  `pmh_osteoporosis` tinyint(1),
  `pmh_breast_dis` tinyint(1),
  `pmh_kidney` tinyint(1),
  `pmh_thyroid` tinyint(1),
  `pmh_std` tinyint(1),
  `pmh_notes` text,
  `psh_year` varchar(10),
  `psh_operation_illness` varchar(20),
  `cm_current_medication` text,
  `habits_cigarettes` tinyint(1),
  `habits_cigperday` varchar(5),
  `habits_alcohol` tinyint(1),
  `habits_alcoholperweek` varchar(5),
  `habits_streetdrugs` tinyint(1),
  `habits_notes` text,
  `allergies` text,
  `additional_notes` text,
  `rfr_abn_pap` tinyint(1),
  `rfr_infertility` tinyint(1),
  `rfr_menorrhagia` tinyint(1),
  `rfr_contraceptivehist` tinyint(1),
  `rfr_irregularperiods` tinyint(1),
  `rfr_ovariancyst` tinyint(1),
  `rfr_fibroids` tinyint(1),
  `rfr_menopause` tinyint(1),
  `rfr_pelvicpain` tinyint(1),
  `rfr_incontinence` tinyint(1),
  `abpap_inflam` tinyint(1),
  `abpap_lgsil` tinyint(1),
  `abpap_previouscolpo_y` tinyint(1),
  `abpap_previouscolpo_n` tinyint(1),
  `abpap_ascus` tinyint(1),
  `abpap_hgsil` tinyint(1),
  `abpap_previoustx_y` tinyint(1),
  `abpap_previoustx_n` tinyint(1),
  `pch_bcp` tinyint(1),
  `pch_nuvo_ring` tinyint(1),
  `pch_IUD` tinyint(1),
  `pch_condoms` tinyint(1),
  `pch_rhythmmethod` varchar(11),
  `pch_vasectomy` tinyint(1),
  `pch_depo_proverainj` tinyint(1),
  `pch_tuballigation` tinyint(1),
  `pch_withdrawal` tinyint(1),
  `pch_evrapatch` tinyint(1),
  `pch_foam` tinyint(1),
  `pch_nobirthcontrolused` tinyint(1),
  `pch_notes` text,
  `fibro_years` varchar(10),
  `fibro_menorrhagia_y` tinyint(1),
  `fibro_menorrhagia_n` tinyint(1),
  `fibro_pelvicpressure_y` tinyint(1),
  `fibro_pelvicpressure_n` tinyint(1),
  `fibro_pelvicpain_y` tinyint(1),
  `fibro_pelvicpain_n` tinyint(1),
  `ultrasound_fibroids` varchar(20),
  `ultrasound_size` varchar(20),
  `ultrasound_cm` varchar(20),
  `incontinence_years` varchar(10),
  `incontinence_frequency_y` tinyint(1),
  `incontinence_frequency_n` tinyint(1),
  `incontinence_urgency_y` tinyint(1),
  `incontinence_urgency_n` tinyint(1),
  `incontinenc_nocturia_y` tinyint(1),
  `incontinenc_nocturia_n` tinyint(1),
  `incontinenc_dysuria_y` tinyint(1),
  `incontinenc_dysuria_n` tinyint(1),
  `incontinenc_sui_y` tinyint(1),
  `incontinenc_sui_n` tinyint(1),
  `infertility_years` varchar(10),
  `infertility_sperm_analysis_y` tinyint(1),
  `infertility_sperm_analysis_n` tinyint(1),
  `infertility_partnerhas_children_y` tinyint(1),
  `infertility_partnerhas_children_n` tinyint(1),
  `infertility_std_y` tinyint(1),
  `infertility_std_n` tinyint(1),
  `infertility_iud_y` tinyint(1),
  `infertility_iud_n` tinyint(1),
  `infertility_pid_y` tinyint(1),
  `infertility_pid_n` tinyint(1),
  `irregularperiods_hirsutism_y` tinyint(1),
  `irregularperiods_hirsutism_n` tinyint(1),
  `irregularperiods_acnea_y` tinyint(1),
  `irregularperiods_acnea_n` tinyint(1),
  `irregularperiods_wtgain_lbs` varchar(10),
  `irregularperiods_wtgain_months` varchar(10),
  `irregularperiods_amenorrhea` varchar(10),
  `irregularperiods_extremeexercise_y` tinyint(1),
  `irregularperiods_extremeexercise_n` tinyint(1),
  `irregularperiods_galactorrhea_y` tinyint(1),
  `irregularperiods_galactorrhea_n` tinyint(1),
  `menopause_amenorrhea_months` varchar(2),
  `menopause_hotflashes_y` tinyint(1),
  `menopause_hotflashes_n` tinyint(1),
  `menopause_insomnia_y` tinyint(1),
  `menopause_insomnia_n` tinyint(1),
  `menopause_nightsweats_y` tinyint(1),
  `menopause_nightsweats_n` tinyint(1),
  `menopause_vaginaldryness_y` tinyint(1),
  `menopause_vaginaldryness_n` tinyint(1),
  `menopause_depressionanxiety_y` tinyint(1),
  `menopause_depressionanxiety_n` tinyint(1),
  `menorrhagia_periods_length` varchar(5),
  `menorrhagia_periods_length_days` varchar(5),
  `menorrhagia_periods_interval` varchar(10),
  `menorrhagia_periods_interval_days` varchar(5),
  `menorrhagia_periods_amountspads_hrs` varchar(5),
  `menorrhagia_imb_y` tinyint(1),
  `menorrhagia_imb_n` tinyint(1),
  `menorrhagia_pcb_y` tinyint(1),
  `menorrhagia_pcb_n` tinyint(1),
  `ovariancyst_years` varchar(10),
  `ovariancyst_pain_y` tinyint(1),
  `ovariancyst_pain_n` tinyint(1),
  `ovariancyst_ultrasound_right` tinyint(1),
  `ovariancyst_ultrasound_left` tinyint(1),
  `ovariancyst_ultrasound_size` varchar(5),
  `characteristics` text,
  `pelvicpain_dysmenorrhea_y` tinyint(1),
  `pelvicpain_dysmenorrhea_n` tinyint(1),
  `pelvicpain_dyspareunia_y` tinyint(1),
  `pelvicpain_dyspareunia_n` tinyint(1),
  `pelvicpain_dyschezia_y` tinyint(1),
  `pelvicpain_dyschezia_n` tinyint(1),
  `pelvicpain_location_rlq_y` tinyint(1),
  `pelvicpain_location_rlq_n` tinyint(1),
  `pelvicpain_location_llq_y` tinyint(1),
  `pelvicpain_location_llq_n` tinyint(1),
  `pelvicpain_suprapublic` tinyint(1),
  `pelvicpain_timingof_pain` tinyint(1),
  `previousinvestigations_bloodwork` tinyint(1),
  `previousinvestigations_hb` varchar(10),
  `previousinvestigations_hormones` varchar(10),
  `previousinvestigations_ultrasound` tinyint(1),
  `previousinvestigations_notes` text,
  `physicalexam_breasts_n` tinyint(1),
  `physicalexam_breasts_abn` tinyint(1),
  `physicalexam_abdomen_n` tinyint(1),
  `physicalexam_abdomen_abn` tinyint(1),
  `physicalexam_notes` text,
  `gynaecologicalexam_genitalia_n` tinyint(1),
  `gynaecologicalexam_genitalia_abn` tinyint(1),
  `gynaecologicalexam_vaginal_n` tinyint(1),
  `gynaecologicalexam_vaginal_abn` tinyint(1),
  `gynaecologicalexam_cervix_n` tinyint(1),
  `gynaecologicalexam_cervix_abn` tinyint(1),
  `gynaecologicalexam_rectum_n` tinyint(1),
  `gynaecologicalexam_rectum_abn` tinyint(1),
  `gynaecologicalexam_uterus_n` tinyint(1),
  `gynaecologicalexam_uterus_abn` tinyint(1),
  `gynaecologicalexam_position_av` tinyint(1),
  `gynaecologicalexam_position_rv` tinyint(1),
  `gynaecologicalexam_size` varchar(10),
  `gynaecologicalexam_adnexa_left_n` tinyint(1),
  `gynaecologicalexam_adnexa_left_abn` tinyint(1),
  `gynaecologicalexam_adnexa_right_n` tinyint(1),
  `gynaecologicalexam_adnexa_right_abn` tinyint(1),
  `gynaecologicalexam_notes` text,
  `investigations_ultrasound` tinyint(1),
  `investigations_bloodwork` tinyint(1),
  `investigations_cbcferritin` tinyint(1),
  `investigations_hormprofile` tinyint(1),
  `investigations_sis` tinyint(1),
  `investigations_tubalpatency` tinyint(1),
  `investigations_menstrualcal` tinyint(1),
  `investigations_bbt` tinyint(1),
  `investigations_spermanalysis` tinyint(1),
  `investigations_notes` text,
  `treatment_bcp` tinyint(1),
  `treatment_bcp1` varchar(10),
  `treatment_cyklokapron` tinyint(1),
  `treatment_anaprox` tinyint(1),
  `treatment_mirena` tinyint(1),
  `treatment_hrt` tinyint(1),
  `treatment_surgery` tinyint(1),
  `treatment_vaginalestrogen` tinyint(1),
  `treatment_notes` text,
  `followup_weeks` tinyint(1),
  `followup_weeks1` varchar(10),
  `followup_afterinvestigations` tinyint(1),
  `followup_anaprox` tinyint(1),
  `provider_no` int(10),
  `formCreated` date,
  `formEdited` timestamp NULL ON UPDATE CURRENT_TIMESTAMP,
  `year1` varchar(5),
  `year2` varchar(5),
  `year3` varchar(5),
  `year4` varchar(5),
  `bpi_date1` date,
  `bpi_date2` date,
  `bpi_date3` date,
  `operation1` text,
  `operation2` text,
  `operation3` text,
  `operation4` text,
  `patient_fname` varchar(60),
  `patient_lname` varchar(60),
  `patient_age` varchar(15),
  `family_doctor_fname` varchar(60),
  `family_doctor_lname` varchar(60),
  `no_med_hist` varchar(2),
  `no_investigations` varchar(2),
  `no_treatments` varchar(2),
  `no_allergies` VARCHAR(2),
  `no_current_medications` VARCHAR(2),
  `prn` varchar(2),
  `appt_date` date,
  PRIMARY KEY (`ID`)
);