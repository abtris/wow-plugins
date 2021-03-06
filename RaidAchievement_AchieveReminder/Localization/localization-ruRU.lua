﻿if GetLocale() == "ruRU" then 


function iclllocaleui()

ralltitle2				= "Данный модуль сообщает, какие достижения доступны в |cff00ff00текущей локации|r, при входе в подземелье. Также может напоминать при взятии босса в цель, который является критерием для одного из достижений. Приставка '|cffff0000не отслеж. аддоном|r' обозначает, что по каким-то причинам аддон не будет отслеживать выполнение достижения и не сообщит, когда оно провалено, '|cffff0000не с босса|r' - критерием достижения является не босс, возможно это объект или что-либо другое. В этом окне дублируется отображение групповых достижений, доступных в текущей локации."
ralltxt1				= "При входе в подземелье сообщает:"
ralltxt2				= "только достижения, не выполненные мною"
ralltxt3				= "все достижения, включая уже выполненные"
ralltxt4				= "только достижения на славу героя/рейдера и не выполненные мною"
ralltxt5				= "только достижения на славу героя/рейдера, даже если они уже выполнены"
ralltxt6				= "FULL версия - ВСЕ достижения, что мне нужны, включая прохождение инста и простое убийство босса"
ralltxt7				= "При взятии босса в цель сообщает:"
ralltxt8				= "только достижения, не выполненные мною"
ralltxt9				= "все достижения, включая уже выполненные"
ralltxt10				= "только достижения на славу героя/рейдера и не сделанные мною"
ralltxt11				= "только достижения на славу героя/рейдера, даже если они уже выполнены"
ralltxt12				= "FULL версия - ВСЕ достижения, что мне нужны, включая прохождение инста и простое убийство босса"
ralltxton				= "(включено)"
ralltxtoff				= "(отключено)"
rallzonenotfound			= "Текущая локация НЕ НАЙДЕНА в базе данных."
rallachiverepl1				= "Не сделанные достижения в"
rallachiverepl2				= "Вы выполнили все достижения в этой локации."
rallachiverepl3				= "Текущая локация не является рейдом или групповым героич. подземельем."
rallachiverepl4				= "Список всех достижений в"
rallachiverepl5				= "Не найдено групповых достижений в базе аддона для этой локации."
rallachiverepl6				= "Проверка отключена."
rallachiverepl7				= "Найдено более 10 достижений (|cff00ff00%s|r). Список доступен в окне настроек аддона (/рач - Список по локации)"
rallachiverepl8				= "Не сделанные достижения на 'славу героя/рейдера' в"
rallachiverepl9				= "Вы выполнили все достижения в этой локации для славы героя/рейдера."
rallachiverepl10			= "Полный список достижений на 'славу героя/рейдера' в"
rallachiverepl11			= "Не найдено групповых достижений на славу героя/рейдера в этой локации."
rallachiverepl12			= "Полный список не сделанных достижений в"
rallachiverepl13			= "Не сделанные достижения с"
rallachiverepl14			= "Список всех достижений с"
rallachiverepl15			= "Не найдено достижений, подходящих под данную критерию с выбранного босса!"
rallachiverepl16			= "Не сделанные достижения на 'славу героя/рейдера' с"
rallachiverepl17			= "Полный список достижений на 'славу героя/рейдера' с"
rallachiverepl18			= "Полный список не сделанных достижений с"
rallnoaddontrack			= "не отслеж. аддоном"
rallnotfromboss				= "не с босса"
rallmenutxt1				= "    Список доступных достижений в текущей локации"
rallachdonel1				= "сделано"
rallachdonel2				= "не сделано"
rallsend				= "Отправить"
rallwhisper				= "в приват:"
rallmenutxt2				= "    Список достижений из выбранной локации"
rallbutton2				= "Выбрать другую локацию"
ralltitle3				= "Данный модуль отображает нужны Вам достижения из |cff00ff00выбранной локации|r. Названия изначально на англ. языке, но при входе в локацию - её локализированное название сохраняется. Вы можете выбрать нужные вам достижения и отправить их в чат"
ralltxt13				= "FULL версия - все достижения с этой локации"
rallbutton3				= "<<< Назад к настройкам"
rallmanualtxt1				= "Дополнение:"
rallmanualtxt2				= "Сложность:"
rallmanualtxt3				= "Локация:"
rallachiverepl19			= "Полный список достижений в"
ralltooltiptxt				= "Отображать на tooltip'е"
ralltooltiptxt2				= "RA: Найдено %s достижений"
ralltooltiptxt21			= "RA: Найденые достижения"
ralltooltiptxt3				= "Подробности: /ра"
rallchatshowboss			= "Отображать в чате"
rallmenutxt3				= "    Тактики на групповые достижения"
ralltitle33				= "Фраза 'тактика: /ра' в чате отображается только для достижений, которые могут вызвать трудности с их выполнением. Здесь же отображены все тактики, очень удобно для новичков, которые впервые попадают в подземелье. Вы можете редактировать текст и отправлять его в чат. Изменения сохраняются для всех Ваших персонажей.\nP.S. Присылайте мне свои комментарии или тактики и они появятся в этом аддоне чтобы помогать другим с выполнением достижений!"
ralltactictext1				= "Выберите достижение:"
ralltactictext2				= "нужна тактика"
ralltactictext3				= "тактика: /ра"
ralluilooktactic1			= "Смотреть тактики"
rallnotfoundachiv1			= "не найдено невыполненных достижений"
rallnotfoundachiv2			= "не найдено достижений"
ralltacticbutsave1			= "Сохранить изменения"
ralltacticbutsave2			= "К изначальной тактике"
ralluilooktactic3			= "|cffff0000Тактики нет|r, видимо в данном достижении нет ничего непонятного. Чтобы |cff00ff00добавить свою тактику - введите здесь текст|r"
ralluilooktactic4			= "Изменения в тактике сохранены."
ralluilooktactic5			= "Тактика"
ralldifparty				= "группа"
ralldifraid				= "рейд"
ralldefaulttacticmain1			= "Аддон подскажет вам в чат, когда можно убивать босса!"
ralldefaulttacticmain2			= "Осторожно: ваши питомцы или тотемы тоже могут провалить достижение!"
ralldefaulttacticmain3			= "Провал достижения сохраняется за копией подземелья и не сбрасывается вайпом"
rallachievekologarnhp1			= "800K - 1 млн"
rallachievekologarnhp2			= "3 млн - 4 млн"

ralldefaulttactic1			= "В каждой из частей города нет 100 зомби, поэтому нужно:\n1. Увести второго босса поближе к таверне где появится Артас (но не заходить в нее)\n2. Дождаться пока восскреснут зомби, которых убили по дороге\n3. Убить второго босса и идти на третьего.\n4. После третьего босса разделиться, 1 дд вернется назад, остальные же пойдут дальше, по команде одновременно начать убивать зомбей в обоих частях города, их там примерно по 80 в каждой"
ralldefaulttactic2			= "Перед боссом будет лестница, на 1 фазе пока сам босс не активен - по ней будут спускаться адды. Требуется убивать их, пока они не спустились вниз"
ralldefaulttactic3			= "Описание: изредка босс использует АоЕ в радиусе 50 м, за каждого игрока, получившего этот урон, босс получает 1 бафф \"Поглощения\"\nТактика: быстро убить босса"
ralldefaulttactic4			= "Убейте нужное количество динозавров во время боя с боссом"
ralldefaulttactic5			= "Вступите в бой с боссом до того, как он поднимется на платформу к игрокам"
ralldefaulttactic6			= "Описание: змеи приползают на помощь боссу. Достижение будет провалено если змея очень долго будет кусать одного и того же человека, увеличивая на нем свой дебаф\nТактика: быстро убить босса, либо быстро убивать змей"
ralldefaulttactic7			= "Требуется не дать боссу прочитать заклинание \"Преображение\", чем меньше у босса ХП, тем быстрее он произносит это заклинание"
ralldefaulttactic8			= "В бою с Эком стойте всегда перед боссом дожидаясь его заклинание \"Плевок Эка\", которые вешает на вас нужный дебафф, проверьте его наличие перед тем как убивать Эка. После же просто убейте последнего босса, умирать нельзя"
ralldefaulttactic9			= "Много непоняток/багов с этим достижением\nОписани: Босс изредка прокалывает одного из игроков, кроме текущего танка. Суть достижения чтобы все игроки получили прокалывание. Поэтому пока ваш танк его не получит - кто-то другой должен танчить босса"
ralldefaulttactic10			= "Босс начинает призывать мелких слизней на 50% и перестанет это делать на 25%. Доведите босса до этих значений и ждите, пока мелкие слизни не превратятся в Железных слякочей, которых и требуется убить"
ralldefaulttactic11			= "Эффект увеличивается каждые пару секунд во время боя с боссом, его можно сбрасывать Рассеиванием магии, либо спрятавшись от босса за глыбы, которые появятся в бою"
ralldefaulttactic12			= "В туннеле к последнему боссу с потолка будут падать сосульки, место падения заранее обозначено синими кругами, избегайте их"
ralldefaulttactic13			= "Начав прохождение подземелья - вверху экрана появится таймер. Если вы успеете дойти до последнего босса, то перед ним (нужно свернуть направо) Вас будет ждать еще 1 - \"Осквернитель из рода Бесконечности\", которого и требуется убить"
ralldefaulttactic14			= "Описание: каждые 30 сек босс выбирает в цель одного из игроков и кастит в него заклинание, после которого на месте игрока появится Оскверненная часть души, этот игрок должен отбежать подальше от босса, так как душа, что появится будет медленно следовать за боссом, и пропадет если догонит его. Когда у босса меньше 35% он телепортируется в центр комнаты и перестает двигаться.\nТактика: Водите босса по кругу на платформе, как только появятся все 4 души - переводите босса  во вторую фазу и быстро убивайте. Оскверненные части души - могут быть замедленны"
ralldefaulttactic15			= "Требуется назначить ротацию для сбивания кастов \"Призрачный взрыв\""
ralldefaulttactic16			= "В определенный момент боя босс станет невосприимчив к урону на 45 сек, переждите это, не убивая хаотические разломы"
ralldefaulttactic17			= "Достижение персональное. Дебафф \"Лютый холод\" увеличивается каждые 2 сек. Действие эффекта прекращается, если Вы двигаетесь. Если стоять на месте более 5 сек - достижение проваливается. Осторожно! у Керистразы есть способность обездвижить вас на 10 сек, быстро рассеивайте этот эффект"
ralldefaulttactic18			= "Описание: Второй босс попадается случайно, это будет либо Исповедница либо Эдрик. Исповедница за бой призывает всего 1 воспоминание из 25 возможных"
ralldefaulttactic19			= "Описание: \"Молот правосудия\" - оглушает противника, делая его уязвимым к \"Молоту праведника\" и не давая ему передвигаться и атаковать в течение 6 сек.\n\"Молот праведника\" - бросает молот, который наносит противнику 14000 ед. урона от светлой магии. Если цель не находится под действием \"Молота правосудия\", то этот молот можно поймать и метнуть обратно в заклинателя.\nТактика: Довести босса до 25К ХП и ждать пока он не повесит на кого-то \"Молот правосудия\", после же - рассеять на этом игроке оглушение и он сможет бросить молот в босса, тем самым добив им его (у игрока появится кнопка на главной панеле)"
ralldefaulttactic20			= "На всех трёх фазах остерегайтесь вурдалаков, проще всего либо убивать их, либо чтоб танк постоянно водил босса, так как вурдалаки долго произносят заклинание взрыва"
ralldefaulttactic21			= "\"Ледяная могила\" - заключает цель в ледяную глыбу. Босс использует это заклинание на 1 из игроков, просто не разбивайте её и убейте босса"
ralldefaulttactic22			= "Рядом с боссом находятся 2 увальня, один из них и потребуется для достижения. На 50% босс начинает \"Ритуал меча\", подведите под падающий меч увальня и убейте его сразу после взрыва, пока на нем остался дебафф"
ralldefaulttactic23			= "Для того чтобы убить Грауфа - требуется кинуть 3 копья с помощью гарпунных установок, когда босс будет напротив них. Для этого достижения требуется кинуть их одновременно"
ralldefaulttactic24			= "Если босса медленно убивать он повесит на себя \"Погибель\", если кто либо нанесет по боссу урон в этот момент - достижение будет провалено. Просто быстро убейте босса"
ralldefaulttactic25			= "Периодически босс будет рассыпаться на много мелких мобов, требуется убивать их пока они не дошли до места, где рассыпался босс, и не слились с ним"
ralldefaulttactic26			= "Кристаллы контроля защиты расположены на стенах подземелья, нажав на которые электрический разряд поможет вам с монстрами. Просто не нажимайте на них и не допускайте мобов к двери тюрьмы"
ralldefaulttactic27			= "Каждый раз, посещая подземелье, Вам будут попадаться всего 2 босса из 6, проявите терпение выполняя данное достижение"
ralldefaulttactic28			= "Если Ан'кахарский страж находится близко к боссу, то босс становится невосприимчив к урону, чтобы убить босса не убивая стражей - просто разведите их на достаточное расстояние"
ralldefaulttactic29			= "Босс ходит между платформ, на которых он останавливается и получает, либо снимает с себя, электрический заряд. Нападите на него, как только он получит этот заряд"
ralldefaulttactic30			= "Изредка босс делает рывок к его наковальне, после чего появляются 2 мелких голема, убейте босса, пока таковых големов не появилось более 4"
ralldefaulttactic31			= "Во время второй фазы (воздушной), если Ониксию долго опускать до 40% - она начинает произносить заклинание \"Дыхание\", пока она готовится его прочесть - всем требуется отбежать от места куда она смотрит (пролетит по прямой до конца комнаты)"
ralldefaulttactic32			= "На 65% Ониксия движется ко входу и начинает взлетать, именно в этот момент и требуется забежать в оба тоннеля с яйцами и пробежаться по ним, на это дается всего 10 сек"
ralldefaulttactic33			= "Снобольдов-вассалов раздает Гормок Пронзающий Бивень, первый босс из троицы. Оставьте вживых %s снобольдов и пройдите все 3 фазы первого испытания"
ralldefaulttactic34			= "Описание: на 1 фазе, до 35% босс периодически закапывается и \"Скарабеи из роя\" вступают в бой, каждый раз это разное количество, и их довольно мало. Случайным образом скарабеи получают бафф \"Берсерк\" и не могут быть замедленны пока заклинание не будет рассеяно\nТактика: затяните бой, дождитесь пока появится достаточное количество скарабеев с запасом и убейте их одновременно"
ralldefaulttactic35			= "Достижение персональное. Лавовые удары это не волны, а метеоры что падают сверху, самый простой способ - умереть в начале боя, либо смотреть вверх и отбегать от них"
ralldefaulttactic36			= "Во время второй фазы боя (50% босса) Малигос взлетает, но спускаются несколько Потомков Вечности. После их убийства остаётся Парящий Диск, на который необходимо сесть и нанести смертельный удар одному из Потомков Вечности, летающих над площадкой. Достижение зарабатывается моментально при нанесении этого удара"
ralldefaulttactic37			= "Требования достижения немного не соответствуют описанию. Требуется убить босса не убивая аддов, либо убить аддов далеко от босса, но ни в коем случае не рядом"
ralldefaulttactic38			= "Описание: Таддиус периодически использует \"Сдвиг полярности\", наделяя всех ближайших противников положительным или отрицательным зарядом (дебафф). Игроки с одинаковым зарядом взаимно увеличивают наносимый ими урон. Игроки с разноименными зарядами наносят урон ближайшим членам рейда и проваливают достижение\nТактика: Разделите рейд на два лагеря (+ и -) и быстро перебегайте при смене полярности в один из них, в зависимости от полученного дебаффа"
ralldefaulttactic39			= "На первой фазе Вам предстоит сразиться с аддами Кел'Тузада, они будут нападать постепенно, но у стен их очень много, атакуйте Поганищ и убивайте нужное количество"
ralldefaulttactic40			= "По ходу боя босс будет насаживать игроков на Костяные шипы (1 в 10ке, 3 в 25ке), которые другие игроки должны быстро убивать"
ralldefaulttactic41			= "Адды появляются в бою только 2 типов, и только на 1 фазе босс может изменять их, убедитесь что у вас собраны все 5 типов перед тем, как переводить босса во вторую фазу и убивать его. Могущественный приверженец не учитывается для получения достижения"
ralldefaulttactic42			= "Совет: тактик много, просто не летайте на вражеский корабль более чем 1 раз"
ralldefaulttactic43			= "При взрыве споры на ближайших игроков вешается эффект \"Невосприимчивость к гнили\" (25% защиты от темной магии), из 3 раз что появляются споры нужно хотя бы раз не получить этот эффект"
ralldefaulttactic44			= "Босс вешает на игрока дебафф, с которого появляется мелкий слизень, если свести 2 слизня - получается большой, если более 4 мелких привести к большому - он взрывается и портит достижение. Проще всего просто не сбегаться и не сводить слизней, а быстро убить босса"
ralldefaulttactic45			= "Способность поганища \"Рвотный слизнюк\" замедляет аддов босса. Просто убивайте аддов без помощи этой способности"
ralldefaulttactic46			= "Чаще всего этот урон получает танк Келесета, ему нужно постоянно держать на себе защитные сферы (Темное ядро), которые уменьшают урон от темной магии на 35%"
ralldefaulttactic47			= "Валитрия открывает по %s портала, в которые и нужно кому-то каждый раз заходить, аддон не отслеживает это достижение в героическом режиме сложности!"
ralldefaulttactic48			= "\"Таинственная энергия\" - Раз в 6 сек. накрывает всех находящихся рядом противников волной тайной магии, увеличивающей весь получаемый магический урон на 10% за каждой применение. Всем требуется постоянно прятаться за Ледяные глыбы и сбрасывать этот дебафф. Сложнее всего это делать танкам, меняться нужно постоянно"
ralldefaulttactic49			= "Описание: \"Мертвящая чума\" - Если противник умирает, находясь под действием чумы, или действие эффекта заканчивается, эффект получает дополнительный заряд и переходит на соседнюю цель. При попытке рассеивания снимается один заряд эффекта, при этом чума также переходит на соседнюю цель.\nТактика: Офф-танк собирает всю мелочь и больших мобов. Проще всего если 1 чуму не относить к аддам, а просто рассеить, а уже все остальные относить к аддам и ждать пока на одном из аддов чума не дойдет до 30 стаков. Как только чумы будет более 30 - перевести босса в следующую фазу, опустив его ХП ниже 70% (аддон подскажет когда пора это делать!)"
ralldefaulttactic50			= "Зловещие духи появляются только на 3 фазе боя (<40%), быстро убивайте их с помощью бойцов дальнего боя. Духи взрываются когда дойдут до кого-то из рейда"
ralldefaulttactic51			= "Требуется собрать большую кучу дворфов (кованых защитников) и после уже начинать быстро убивать их. Достижение можно сделать самому, без чей-либо помощи"
ralldefaulttactic52			= "Пассажиры разрушителей могут быть катапультированы на Левиафана, только они могут получить это достижение. Но если убить все пушки на боссе то другое достижение \"Остановка\" будет провалено"
ralldefaulttactic53			= "Остановка босса происходит если убить все его пушки, которые могут убивать только десантники, катапультированные из разрушителей"
ralldefaulttactic54			= "\"Шлаковый ковш\" - Захватывает случайного противника и помещает его в шлаковый ковш заклинателя. Цель получает урон от огня каждую секунду в течение 10 сек. Текущий танк босса не может получить это заклинание"
ralldefaulttactic55			= "Чтобы разбить железные создания - их нужно сначала раскалить в огне (до 10 стаков), а потом завести в воду, где они получат дебафф \"Ломкость\" - Под воздействием холодной воды железные создания быстро застывают и не могут двигаться. Если в этом состоянии они получают больше 5000 единиц урона, создания раскалываются. Требуется убить 2 штуки почти одновременно"
ralldefaulttactic56			= "Достижение может выполняться постепенно. Необходимо собирать всех мобов, доводить их до ~15К ХП, и держать перед боссом, перед тем как босс взлетает - она дышит перед собой, тем самым может убить аддов, достижение засчитывается и от дыхания на 2 фазе"
ralldefaulttactic57			= "Босса нужно перевести во вторую фазу (50%) не более чем за 2 её приземления"
ralldefaulttactic58			= "Описание достижения неверное. Что требуется сделать - сложно сказать"
ralldefaulttactic59			= "Когда сердце босса становится активным - с 4 куч по углам начинают идти адды, самые мелкие не должны добраться до босса"
ralldefaulttactic60			= "Нужно перевести босса в фазу сердца, опустить ХП сердца как можно ниже но не убить, тогда сразу же после этого снова будет эта же фаза. С куч мусора постоянно будут идти адды, их нужно замедлять, как соберется достаточное количество - одновременно взрывать бомбы, которые умирая взорвут мелких рядом"
ralldefaulttactic61			= "Продается в грозовой гряде. Пить лучше перед самым концом боя, когда вы уверены в победе, так как у нее большая перезарядка"
ralldefaulttactic62			= "Всем стать в мили радиусе босса, кроме 2-3 человек, на которых и будут появляться эти лучи. Учтите, что лучи всегда появляются по бокам персонажа, поэтому удобнее стоять боком к боссу, чтобы сразу побежать просто прямо"
ralldefaulttactic63			= "Бить босса запрещено, нужно по очереди убивать руки и ожидать пока они появятся снова"
ralldefaulttactic64			= "Доводим босса до %s ХП, опускаем ХП обоих рук до минимума и одновременно убиваем его руки"
ralldefaulttactic65			= "Убивать дикого защитника придется долго, как и говорит название достижения - у него 9 жизней. Убивайте и ждите пока он не появится снова, аддон напишет когда у него будет оставаться последняя жизнь, будьте готовы, что после убийства защитника у вас будет мало времени на убийство босса, берсерк будет близко"
ralldefaulttactic66			= "Достижение персональное. Получите бафф \"Грозовая энергия\", найдите луч света недалеко от костра и станьте в него"
ralldefaulttactic67			= "Вовремя разбивайте ледяные ловушки с ваших помощников - NPC"
ralldefaulttactic68			= "Во время чтение боссом заклинания \"Ледяная вспышка\", упадут 3 сосульки образуя сугробы, на которые и нужно успеть забежать до завершения чтения заклинания боссом, кто не успеет - попадет в ледяную ловушку"
ralldefaulttactic69			= "Трескучий мороз появляется на персонаже если не двигаться, почаще передвигайтесь либо стойте у костров, которые убирают этот эффект"
ralldefaulttactic70			= "Ходир уничтожает свои сокровища через 3 минуты после начала боя"
ralldefaulttactic71			= "К одной из сфер у стены босс начнет пускать электрический заряд, через несколько секунд туда полетят молнии (конусом от босса), нужно отбегать от этого места"
ralldefaulttactic72			= "Изначально достижение требовало побывать в тоннеле, которым начинают бой, но это убрали и теперь нужно просто убить босса"
ralldefaulttactic73			= "На 1 фазе жрец должен законтролить (контроль разума) \"Завоеватель из клана Темных Рун\" и держать его до конца боя, на момент убийства босса - моб должен находиться в контроле. Примечание: аура вешается в радиусе 40 ярдов от моба"
ralldefaulttactic74			= "На 1 фазе будет 6 волн аддов, убейте 5 из них и убейте босса оставив одну из волн вживых до конца боя"
ralldefaulttactic75			= "Достижение можно выполнять постепенно. Постарайтесь не наступить на мину на 1 и 4 фазе, быстро убивать Бомботов на 3 фазе, и не попасть под Ракетный залп на 2 и 4 фазе"
ralldefaulttactic76			= "Одного из штурмботов с 3 фазы нужно завести под Ракету на 4 фазе"
ralldefaulttactic77			= "Сложный режим босса. Нельзя убивать саронитовые пары, а так же требуется дождаться появление адда, и убить его перед убийством самого босса"
ralldefaulttactic78			= "При переходе босса во 2 фазу, взять в цель Сару и использовать эмоцию \"поцелуй\", либо сделать макро:\n /ц Сара\n /поцелуй"
ralldefaulttactic79			= "Заходите в порталы на 2 фазе, пока не попадете во все 3 комнаты-видения"
ralldefaulttactic80			= "Следите за эффектом \"Здравомыслие\", если оно опустится до 0 - вы сойдете с ума. Сильно опускается на 3 фазе, если смотреть на босса во время чтения им заклинания \"Взгляд безумца\". В простом режиме здравомыслие можно восполнять в зеленых лучах Фреи"
ralldefaulttactic81			= "После убийства \"Вспыхивающей звезды\" на её месте образуется \"Черная дыра\",  если завести в эту дыру \"Живое созвездие\" то она закроется, суть достижения завести 3 созвездия в течении 10 секунд"
ralldefaulttactic82			= "Счетчик убитых крыс не обнуляется, поэтому вы можете делать достижение постепенно. Достижение вы получите сразу, без необходимости убивать босса"
ralldefaulttactic83			= "Опытная модель жнеца имеет иммунитет к урону от огненных аддов, поэтому убивайте их жнецом подальше от босса. Возможно баг: достижение проваливается даже если ХП жнеца опустятся ниже 90% на треше, ДО боя с боссом"
ralldefaulttactic84			= "Достижение персональное. Босс использует заклинание \"Стена огня\" на протяжении всей 2ой фазы"
ralldefaulttactic85			= "После каждого заклинания 'Удушить' босс использует потоковое заклинание лечения 'Отложенная расправа' - прерывайте его моментально"
ralldefaulttactic86			= "Адды (не босс) используют 'Нечистое могущество' - прерывайте все заклинания в течении всего боя"
ralldefaulttactic87			= "Когда приходят адды - заведите одного из них в Гейзер. Для получения достижения не требуется убивать босса, оно будет выданно моментально при смерти адда"
ralldefaulttactic88			= "Не убивайте Непреклонное чудовище пока вы не получите 'Гнев прилива' на 3ей фазе"
ralldefaulttactic89			= "Позвольте Ревнителям Корлы развиться 1 за 1 и быстро убейте их (пока они не убили вашего танка). Адды развиваются если не стоять на пути луча"
ralldefaulttactic90			= "Персональное достижение. Прыгайте во время заклинания 'Хватка природы' - таким образом вы не попадете под его действие. Лучший способ получить это достижение - постоянно прыгать"
ralldefaulttactic91			= "Чтобы босс получил бафф 'Проклятие Модгуд' - убейте зараженного адда рядом с ним. Осторожно: 'Проклятие Модгуд' - Увеличивает наносимый урон на 100%"
ralldefaulttactic92			= "Достижение выдается всей группе. Золотые сферы расположены в определенных местах в подземелье, их больше 5. К примеру, 2 из них находятся над платформой 2го босса, чтобы получить их, требуется воспользоваться смерчем в бою с боссом"
ralldefaulttactic93			= "На второй, сумеречной, фазе спавнятся души из игроков. Надо сделать так, чтобы они прошли через огонь, который оставил феникс на первой фазе; на душах появляется бафф, в этот момент их и нужно убить. Достижение будет выдано сразу после убийства 3 адда"




end



end