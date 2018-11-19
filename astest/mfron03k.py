# coding=utf-8
# --------------------------------------------------------------------
# Copyright (C) 1991 - 2018 - EDF R&D - www.code-aster.org
# This file is part of code_aster.
#
# code_aster is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# code_aster is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with code_aster.  If not, see <http://www.gnu.org/licenses/>.
# --------------------------------------------------------------------
from code_aster.Commands import DEFI_COMPOR 

def F_COMPORP(COMPORT, MU) : 

	COMPORP=DEFI_COMPOR(
		                POLYCRISTAL=(
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(27.20854918326857, 318.67802797505612, 285.59944509903261),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(72.32857267521139, 280.85122491848551, 261.24839431882481),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(246.51635285271027, 256.21031979247977, 99.114529794558024),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(254.22079786962831, 302.68210854687476, 109.95436169084806),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(24.54318511735568, 182.29348103325626, 239.70882316972981),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(4.0085823868013026, 215.08644816345415, 187.39413316280411),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(331.48165491663065, 72.055653061967917, 9.2464652881341625),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(351.37283453335158, 71.548249029849643, 253.41523460935855),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(193.29321600368706, 63.073891600335955, 329.20140363407393),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(74.795125230191289, 150.32992634144895, 261.07899074241482),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(110.18609025875581, 243.30105200739459, 279.08071318467336),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(55.228430424056377, 205.03358841586018, 294.98104591895884),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(227.39528795722089, 251.52957460134567, 110.45139253343493),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(16.363674288091367, 176.55346069611352, 157.58830432033722),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(246.00188184797457, 309.61563611199068, 9.2232020805091963),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(268.87173371631798, 152.89950249828064, 347.60907500066577),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(278.47633171697402, 225.55559409937311, 232.63917276413679),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(38.188514500080956, 64.668235103510554, 215.79975517350985),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(234.91874805568307, 152.40468004029958, 188.87027106018769),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(145.69534373581681, 140.03800905604373, 76.106065337097519),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(123.92855461686725, 172.68719339152011, 343.86023087100727),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(170.70310363174374, 200.75926970851907, 345.15923464062172),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(339.60652159723219, 182.18381197362316, 105.2764380840033),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(150.82107069669092, 140.44832109459347, 171.44599440831507),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(315.67373145396488, 145.43873550950394, 154.12004801377986),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(52.362874388495356, 242.46045763295825, 88.379619777028353),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(18.693903660974609, 294.82095770781575, 299.01340588718477),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(161.82132486319776, 321.72963095589751, 332.92681859296448),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(41.946741753366545, 275.30650947255435, 225.84233040195301),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(32.699739706484856, 127.77742750257185, 256.79520399061204),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(83.093273011287408, 83.136538132047576, 336.54676493495225),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(42.111980405643806, 213.95633904621124, 331.55827875878396),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(160.44419802369083, 175.20403710117321, 0.92922297976434365),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(341.50280298195872, 144.6160060883725, 165.98038155957937),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(129.86520048544409, 3.9462617286959434, 256.10357201908982),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(87.901468681664312, 52.048390991864068, 202.65428202555825),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(6.233792527193418, 128.50423518186579, 128.64861886558234),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(96.321527944747643, 99.265605274052746, 68.232178855457803),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(298.60955178310269, 75.897690479768727, 35.312905802580104),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(156.36860095677193, 206.51797337810973, 283.84274222279788),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(262.42987712649727, 121.80268157924218, 47.510830680250521),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(123.03600222123471, 101.84511077965962, 351.92806385590956),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(262.12423536728949, 204.06874026891563, 165.84842280824438),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(66.715806930646551, 38.966003573835629, 146.05682194620991),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(72.070866944872378, 67.184059090710534, 225.38357248781767),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(7.5058420149616012, 108.41618671021911, 227.02418853272903),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(12.053426259566509, 305.66442420368401, 108.34075543516511),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(227.34110835221418, 252.38738470503733, 150.33720949109238),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(16.259366535890322, 159.1487448291615, 338.4911605358331),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(31.80029295812901, 72.039903910934555, 330.19875073520757),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(295.2929566202219, 211.03451281056152, 8.4997310347443431),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(258.25351466310485, 196.68577888686002, 77.727230629844712),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(245.54497303889502, 69.805434679890212, 298.12092586580548),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(190.55473488479075, 276.43817116610541, 188.53536495944999),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(76.382443756650062, 87.314187995439738, 122.69473546435106),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(40.444154481703116, 309.83497259493731, 208.81378132530762),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(164.06990836968197, 45.851106327579494, 170.80574863811853),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(171.94403314741351, 197.90860978994434, 277.24623306672572),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(122.23796204176753, 116.53547157490944, 321.67984695363896),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(191.93939649512316, 256.76755603510048, 192.43665549617052),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(66.03282232785503, 221.87195563720309, 241.08009080066262),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(180.46832391663841, 136.36197033407839, 35.977906668787931),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(292.00514388123378, 94.066941918315806, 339.63878864830821),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(29.420769394606758, 201.09421557033531, 64.240715707499646),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(214.21569414728171, 173.42533536950535, 221.97946452004558),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(106.53434742851505, 266.12173083757091, 236.80078878911422),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(227.24643497587905, 306.46585806426464, 47.013905411861202),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(107.20354414407846, 267.84370716072965, 154.12824499823572),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(354.52088251514573, 160.03224020000906, 208.62871994506074),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(70.410572573716323, 271.59672138411389, 2.9257754398228109),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(44.919064550729189, 147.54631811299276, 290.71050128329364),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(213.07280644804104, 62.712875879136611, 120.43043363899258),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(216.89033298209134, 348.20543408303416, 141.67892422293122),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(353.79265794930751, 143.45851956594345, 61.698705529816131),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(172.14121870836422, 34.324608397138554, 217.33276096263356),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(316.94737464424077, 124.00882943710248, 47.235487454027435),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(51.430453182630657, 249.93704791336933, 320.85153192142826),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(170.5107718472313, 265.49266181659044, 176.03727382244804),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(322.57168457266425, 181.98928095004632, 134.0367213595531),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(194.58310733595687, 321.30715122154959, 235.05686405605576),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(85.323376587738167, 122.56184302372563, 52.337812325352012),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(11.744360783101712, 139.82719190615583, 103.96637631855029),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(137.88912721648086, 269.42247066518576, 356.88098892473289),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(349.68510083357268, 205.35997800189247, 191.22491084042301),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(6.1229296198929228, 123.25745525880374, 115.65039262941539),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(52.155895962972885, 195.37529238031988, 19.363228712547095),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(234.11062790042314, 233.73529290079134, 214.23092148067448),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(5.1218898266836321, 80.769287099409752, 88.825906335132757),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(221.29559504034754, 258.47124275562891, 76.558538375881781),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(203.06199977706217, 326.27582843627908, 330.32620575426364),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(353.42244617868289, 239.86808976207723, 32.157145150020597),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(18.602648266049844, 101.03828837398272, 248.49979474419217),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(103.71811795572717, 198.49253870465515, 86.043157302138894),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(43.742015302114964, 180.16109395369492, 58.798610724353075),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(21.112112992909129, 199.04199041700329, 43.548360130905614),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(259.72297430907082, 126.77044500506274, 217.76809967807077),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(251.80862548493772, 192.47171395073002, 97.730191691613982),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(26.992677507732129, 268.11756481051447, 180.8973383246084),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(241.28759966229376, 61.888838262650957, 343.30079732904699),),
		                             _F(MONOCRISTAL=COMPORT,FRAC_VOL=0.01,ANGL_EULER=(169.42871440599433, 195.88172809658724, 62.678421538707326),),
		                             ),
		                              LOCALISATION='BZ',
		                              MU_LOCA=MU,
		                )
	return COMPORP
