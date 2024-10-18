defmodule Krug.MathUtilTest do
  use ExUnit.Case
  
  doctest Krug.MathUtil
  
  alias Krug.MathUtil
  
  test "[validate_url(path)]" do
    assert MathUtil.pow(3,1000) == 1322070819480806636890455259752144365965422032752148167664920368226828597346704899540778313850608061963909777696872582355950954582100618911865342725257953674027620225198320803878014774228964841274390400117588618041128947815623094438061566173054086674490506178125480344405547054397038895817465368254916136220830268563778582290228416398307887896918556404084898937609373242171846359938695516765018940588109060426089671438864102814350385648747165832010614366132173102768902855220001
    assert MathUtil.pow(3,10000) == 16313501853426258743032567291811547168121324535825379939348203261918257308143190787480155630847848309673252045223235795433405582999177203852381479145368112501453192355166224391025423628843556686559659645012014177448275529990373274425446425751235537341867387607813619937225616872862016504805593174059909520461668500663118926911571773452255850626968526251879139867085080472539640933730243410152186914328917354576854457274195562218013337745628502470673059426999114202540773175988199842487276183685299388927825296786440252999444785694183675323521704432195785806270123388382931770198990841300861506996108944782065015163410344894945809337689156807686673462563038164792190665340124344133980763205594364754963451564072340502606377790585114123814919001637177034457385019939060232925194471114235892978565322415628344142184842892083466227875760501276009801530703037525839157893875741192497705300469691062454369926795975456340236777734354667139072601574969834312769653557184396147587071260443947944862235744459711204473062937764153770030210332183635531818173456618022745975055313212598514429587545547296534609597194836036546870491771927625214352957503454948403635822345728774885175809500158451837389413798095329711993092101417428406774326126450005467888736546254948658602484494535938888656542746977424368385335496083164921318601934977025095780370104307980276356857350349205866078371806065542393536101673402017980951598946980664330391505845803674248348878071010412918667335823849899623486215050304052577789848512410263834811719236949311423411823585316405085306164936671137456985394285677324771775046050970865520893596151687017153855755197348199659070192954771308347627111052471134476325986362838585959552209645382089055182871854866744633737533217524880118401787595094060855717010144087136495532418544241489437080074716158404895914136451802032446707961058757633345691696743293869623745410870051851590672859347061212573446572045088465460616826082579731686004585218284333452396157730036306379421822435818001505905203918209206969662326706952623512427380240468784114535101496733983401240219840048956733689309620321613793757156727562461651933397540266795963865921590913322060572673349849253303397874242381960775337182730037783698708748781738419747698880321601186310506332869704931303076839444790968339306301273371014087248060946851793697973114432706759288546077622831002526800554849696867710280945946603669593797354642136622231192695027321229511912952940320879763123151760555959496961163141455688278842949587288399100273691880018774147568892650186152065335219113072582417699616901995530249937735219099786758954892534365835235843156112799728164123461219817343904782402517111603206575330527850752564642995318064985900815557979945885931124351303252811255254295797082281946658798705979077492469849644183166585950844953164726896146168297808178398470451561320526180542310840744843107469368959707726836608471817060598771730170755446473440774031371227437651048421606224757527085958515947273151027400662948161111284777828103531499488913672800783167888051177155427285103861736658069404797695900758820465238673970882660162285107599221418743657006872537842677883708807515850397691812433880561772652364847297019508025848964833883225165668986935081274596293983121864046277268590401580209059988500511262470167150495261908136688693861324081559046336288963037090312033522400722360882494928182809075406914319957044927504420797278117837677431446979085756432990753582588102440240611039084516401089948868433353748444104639734074519165067632941419347985624435567342072815910754484123812917487312938280670403228188813003978384081332242484646571417574404852962675165616101527367425654869508712001788393846171780457455963045764943565964887518396481296159902471996735508854292964536796779404377230965723361625182030798297734785854606060323419091646711138678490928840107449923456834763763114226000770316931243666699425694828181155048843161380832067845480569758457751090640996007242018255400627276908188082601795520167054701327802366989747082835481105543878446889896230696091881643547476154998574015907396059478684978574180486798918438643164618541351689258379042326487669479733384712996754251703808037828636599654447727795924596382283226723503386540591321268603222892807562509801015765174359627788357881606366119032951829868274617539946921221330284257027058653162292482686679275266764009881985590648534544939224296689791195355783205968492422636277656735338488299104238060289209390654467316291591219712866052661347026855261289381236881063068219249064767086495184176816629077103667131505064964190910450196502178972477361881300608688593782509793781457170396897496908861893034634895715117114601514654381347139092345833472226493656930996045016355808162984965203661519182202145414866559662218796964329217241498105206552200001
  end
  
  test "[round_precision(number,precision)]" do
    assert MathUtil.round_precision(2.12345,2) == 2.12
    assert MathUtil.round_precision(2.1249,2) == 2.12
    assert MathUtil.round_precision(2.125,2) == 2.13
    assert MathUtil.round_precision(2.12901,2) == 2.13
    assert MathUtil.round_precision(4.567490,3) == 4.567
    assert MathUtil.round_precision(4.567500,3) == 4.568
    assert MathUtil.round_precision(4.567990,3) == 4.568
    assert MathUtil.round_precision(6.345,0) == 6
    assert MathUtil.round_precision(6.345,1) == 6.3
    assert MathUtil.round_precision(6.345,2) == 6.35
    assert MathUtil.round_precision(6.345,3) == 6.345
    assert MathUtil.round_precision(6.345,4) == 6.345
    assert MathUtil.round_precision(6.345,5) == 6.345
    assert MathUtil.round_precision(6.345,6) == 6.345
  end
  
end