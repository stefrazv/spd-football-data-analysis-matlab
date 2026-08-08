%in caz ca da eroare la run: cd('E:\spd\proiect_serios_spd')

%------------------------------------------------------------------------------------------------

% CERINTA 2: IMPORTAREA SI PREPROCESAREA DATELOR

% Motivatie: Datele brute provin din doua surse separate (performante si
% profiluri), deci primul pas este jonctiunea dupa player_id pentru a obtine
% un set unificat. Curatarea este necesara deoarece valorile lipsa la goluri,
% pase sau cartonase sunt cel mai probabil zerouri neraportate, nu date
% cu adevarat absente. Excludem portarii deoarece metricile lor de performanta
% (goluri, pase decisive) sunt structural diferite fata de jucatorii de camp,
% ceea ce ar distorsiona orice analiza ulterioara. Filtrul de 90 de minute
% elimina jucatorii fara timp real de joc, iar limitele de inaltime (150-210 cm)
% inlatura erorile de introducere a datelor. Esantionarea la 120.000 de
% inregistrari asigura un volum de date gestionabil fara a pierde
% reprezentativitatea statistica.

disp(' ')
disp('---------- Cerinta 2: Importarea si preprocesarea datelor ----------')
disp(' ')

% ------ Codul de mai jos (jonctiunea) a fost utilizat pentru generarea 
% setului de date final. Pentru predare, am comentat procesarea bruta 
% si incarcam direct fisierul rezultat 'set_date_fotbal_final.csv'.


disp('Se citesc datele brute...');
performante = readtable('player_performances.csv');
profil_jucatori = readtable('player_profiles.csv');

disp('Se realizeaza jonctiunea tabelelor...');
dateComplete = innerjoin(performante, profil_jucatori, 'Keys', 'player_id');
coloane = {'player_id', 'position', 'goals', 'assists', 'yellow_cards', 'minutes_played', 'height'};
dateSelectate = dateComplete(:, coloane);

disp('Curatam datele lipsa...');
dateSelectate.goals(isnan(dateSelectate.goals)) = 0;
dateSelectate.assists(isnan(dateSelectate.assists)) = 0;
dateSelectate.yellow_cards(isnan(dateSelectate.yellow_cards)) = 0;
dateCurate = rmmissing(dateSelectate);

dateCurate.position = categorical(dateCurate.position);
dateCurate = dateCurate(dateCurate.position ~= 'Goalkeeper', :);
dateCurate.position = removecats(dateCurate.position); 

dateCurate = dateCurate(dateCurate.height >= 150 & dateCurate.height <= 210, :);
dateCurate = dateCurate(dateCurate.minutes_played >= 90, :);

if height(dateCurate) > 120000
    indici_aleatori = randperm(height(dateCurate), 120000);
    dateCurate = dateCurate(indici_aleatori, :);
end

writetable(dateCurate, 'set_date_fotbal_final.csv');
disp('Fisierul "set_date_fotbal_final.csv" a fost generat.');


% --- INCARCARE DIRECTA PENTRU PREZENTARE ---
disp('Se incarca setul de date final prelucrat...');
dateCurate = readtable('set_date_fotbal_final.csv');

% Obligatoriu: Convertim coloana text inapoi in categorica
dateCurate.position = categorical(dateCurate.position);

% Afisam sumarul pentru confirmare
summary(dateCurate);

disp(' ')

%------------------------------------------------------------------------------------------------

% CERINTA 3: PREZENTAREA UNOR PARAMETRI STATISTICI CHEIE

% Motivatie: Golurile si pasele decisive sunt variabile puternic asimetrice
% (majoritatea jucatorilor au 0 goluri), deci media singura ar induce in eroare.
% Calculam un set complet de indicatori (mediana, modul, IQR) tocmai pentru a
% surprinde aceasta asimetrie. Contrastul dintre medie si mediana ne va arata
% cat de mult "trag" in sus jucatorii de elita. Pentru inaltime, ne asteptam
% la o distributie mai simetrica, ceea ce vom confirma prin valorile apropiate
% ale mediei si medianei.


disp(' ')
disp('---------- Cerinta 3: Prezentarea unor parametri statistici cheie ----------')
disp(' ')

% Extragem variabilele de interes
goluri = dateCurate.goals;
pase = dateCurate.assists;
inaltime = dateCurate.height;


% 1. Analiza pentru GOLURI
disp('--- 1. Parametri statistici pentru GOLURI ---');
fprintf('Media: %.2f goluri pe sezon\n', mean(goluri));
fprintf('Mediana: %.0f goluri (Jucatorul "din mijloc")\n', median(goluri));
fprintf('Modulul: %.0f goluri (Cea mai frecventa valoare)\n', mode(goluri));
fprintf('Abaterea standard: %.2f\n', std(goluri));
fprintf('Amplitudinea (Range): %.0f\n', max(goluri) - min(goluri));
fprintf('Interval intercuartilic (IQR): %.0f\n\n', iqr(goluri));

% -------------------------------------------------------
% 2. Analiza pentru PASE DECISIVE (Assists)

disp('--- 2. Parametri statistici pentru PASE DECISIVE ---');
fprintf('Media: %.2f pase pe sezon\n', mean(pase));
fprintf('Mediana: %.0f pase\n', median(pase));
fprintf('Modulul: %.0f pase\n', mode(pase));
fprintf('Abaterea standard: %.2f\n', std(pase));
fprintf('Amplitudinea (Range): %.0f\n', max(pase) - min(pase));
fprintf('Interval intercuartilic (IQR): %.0f\n\n', iqr(pase));

% -------------------------------------------------------
% 3. Analiza pentru INALTIME (Height)

disp('--- 3. Parametri statistici pentru INALTIME ---');
fprintf('Media: %.1f cm\n', mean(inaltime));
fprintf('Mediana: %.0f cm\n', median(inaltime));
fprintf('Modulul: %.0f cm\n', mode(inaltime));
fprintf('Abaterea standard: %.2f cm\n', std(inaltime));
fprintf('Amplitudinea (Range): %.0f cm\n', max(inaltime) - min(inaltime));
fprintf('Interval intercuartilic (IQR): %.0f cm\n\n', iqr(inaltime));

%------------------------------------------------------------------------------------------------

% CERINTA 4: ANALIZA FOLOSIND BOXPLOT

% Motivatie: Dupa ce am calculat parametrii numerici la cerinta anterioara,
% avem nevoie de o reprezentare vizuala care sa compare simultan distributiile
% pe fiecare pozitie (Defender, Forward, Midfielder). Boxplot-ul este ideal
% deoarece rezuma in acelasi grafic: tendinta centrala (mediala), dispersia
% (IQR) si valorile aberante. Aplicam regula 1.5 * IQR pentru a-i identifica
% pe atacantii de elita — jucatorii ale caror performante depasesc cu mult
% norma pozitiei lor.

disp(' ')
disp('---------- Cerinta 4: Analiza folosind BOXPLOT  ----------')
disp(' ')

% 1. Calculul cuartilelor folosind functia de baza quantile
% Q1 reprezinta valoarea sub care se afla 25% din date, iar Q3 pentru 75%
Q_calc = quantile(goluri, [0.25, 0.75]);
Q1 = Q_calc(1);
Q3 = Q_calc(2);

% 2. Calculul limitelor pentru valorile aberante (Metoda 1.5 * IQR din Lab 6)
% Folosim iqr-ul calculat la cerinta anterioara (sau Q3 - Q1)
iqr_B = Q3 - Q1; 
lim_inf = Q1 - 1.5 * iqr_B;
lim_sup = Q3 + 1.5 * iqr_B;

% 3. Extragerea valorilor aberante (Outliers) din sirul de goluri
% Ne intereseaza jucatorii de elita (care depasesc limita superioara)
outliers_goluri = goluri(goluri > lim_sup);
nr_outliers = length(outliers_goluri);

fprintf('Cuartila inferioara (Q1): %.0f\n', Q1);
fprintf('Cuartila superioara (Q3): %.0f\n', Q3);
fprintf('Limita superioara pt outliers (Q3 + 1.5 * IQR): %.2f\n', lim_sup);
fprintf('Am gasit %d atacanti de elita (valori aberante peste %.2f goluri)\n', nr_outliers, lim_sup);

% 4. Reprezentarea grafica (Diagrama Boxplot)
% Aceasta permite diagnosticarea vizuala a asimetriei distributiei
figure; 
boxplot(dateCurate.goals, cellstr(dateCurate.position));

% Estetica graficului
title('Distributia Golurilor pe Pozitii in Teren (Detectia Outliers)');
xlabel('Pozitia Jucatorului');
ylabel('Numar de Goluri Marcate');
grid on;

%------------------------------------------------------------------------------------------------

% CERINTA 5: TEOREMA DE LIMITA CENTRALA

% Motivatie: Distributia golurilor este puternic asimetrica spre dreapta
% (putini jucatori marcheaza mult, majoritate marcheaza 0), deci nu poate fi
% modelata direct ca normala. Teorema Limitei Centrale justifica de ce putem
% aplica totusi teste statistice parametrice (cum e testul t de la cerinta 8):
% indiferent de forma distributiei originale, mediile unor esantioane suficient
% de mari (n=50) se distribuie normal. Demonstram acest lucru empiric prin
% 3000 de esantioane, comparand histograma originala cu cea a mediilor.

disp(' ')
disp('---------- Cerinta 5: Teorema de limita centrala ----------')
disp(' ')

% Alegem o variabila numerica puternic asimetrica (Golurile) pentru a
% demonstra utilitatea Teoremei de limita centrala
populatie_goluri = dateCurate.goals;

figure('Name', 'Cerinta 5: Teorema de Limita Centrala');
subplot(1, 2, 1);
histogram(populatie_goluri, 'FaceColor', '#0072BD');
title('Distributia Originala a Golurilor');
xlabel('Goluri'); ylabel('Frecventa');

% Extragem m esantioane si calculam media fiecaruia
nr_esantioane = 3000;
n_esantion = 50; 
medii_esantioane = zeros(1, nr_esantioane);

for i = 1:nr_esantioane
    esantion = populatie_goluri(randperm(length(populatie_goluri), n_esantion));
    medii_esantioane(i) = mean(esantion);
end

subplot(1, 2, 2);
histfit(medii_esantioane); % Compara distributia cu cea normala
title('Distributia Mediilor (CLT)');
xlabel('Media Golurilor'); ylabel('Frecventa');
disp('S-a generat graficul pentru Teorema de Limita Centrala.');

%------------------------------------------------------------------------------------------------

% CERINTA 6: ESTIMAREA UNUI PARAMETRU STATISTIC

% Motivatie: In practica, rareori avem acces la intreaga populatie de jucatori.
% Simulam acest scenariu real extragand repetat esantioane mici (n=30) si
% estimand parametrii populatiei exclusiv din acestea. Am ales 50 de esantioane
% pentru a reduce influenta aleatoritatii unui singur esantion: media
% estimatorilor converge catre valoarea reala a populatiei pe masura ce numarul
% de esantioane creste. Am ales variabila "inaltime" deoarece prezinta o
% distributie aproape simetrica, ceea ce valideaza utilizarea mediei si
% variantei ca estimatori reprezentativi.

disp(' ');
disp('---------- Cerinta 6: Estimarea unui parametru statistic ----------')
disp(' ')

% Estimam media si abaterea pentru variabila "inaltime"
populatie_inaltime = dateCurate.height;

nr_esantioane_est = 50;
n_est = 30;
est_medii = zeros(1, nr_esantioane_est);
est_dispersii = zeros(1, nr_esantioane_est);

for i = 1:nr_esantioane_est
    esantion_h = populatie_inaltime(randperm(length(populatie_inaltime), n_est));
    est_medii(i) = mean(esantion_h);
    est_dispersii(i) = var(esantion_h); % estimatorul dispersiei
end

medie_estimata = mean(est_medii);
abatere_estimata = sqrt(mean(est_dispersii));

fprintf('Media estimata a inaltimii: %.2f cm\n', medie_estimata);
fprintf('Abaterea estimata a inaltimii: %.2f cm\n', abatere_estimata);

%------------------------------------------------------------------------------------------------

% CERINTA 7: ESTIMAREA PRIN INTERVALE DE INCREDERE

% Motivatie: La cerinta 6 am obtinut un singur punct de estimare (media
% estimata), insa acesta nu ofera nicio informatie despre incertitudinea
% estimarii. Intervalul de incredere de 95% rezolva acest lucru: ne spune
% intre ce limite se afla cu mare probabilitate media reala a inaltimii
% in populatia totala. Cu cat esantionul este mai mic sau abaterea mai mare,
% cu atat intervalul va fi mai larg — reflectand mai multa incertitudine.
% Folosim distributia t-Student (si nu distributia normala Z) deoarece
% dispersia reala a populatiei nu este cunoscuta, ci a fost ea insasi
% estimata din esantioane la cerinta anterioara. Distributia t corecteaza
% aceasta incertitudine suplimentara, avand cozi mai late decat normala —
% efect vizibil mai ales la esantioane mici (n=30).

disp(' ');
disp('---------- Cerinta 7: Estimarea prin intervale de incredere ----------')
disp(' ')

% Folosim un coeficient de incredere de 95% (alfa = 0.05)
alfa = 0.05; 
t_alfa_2 = tinv(1 - alfa/2, n_est - 1); % valoare din tabelul t-Student

% Eroarea se calculeaza folosind formula din curs
eroare = t_alfa_2 * (abatere_estimata / sqrt(n_est));

limita_inf = medie_estimata - eroare;
limita_sup = medie_estimata + eroare;

fprintf('Cu o certitudine de 95%%, media reala a inaltimii jucatorilor se afla in intervalul:\n');
fprintf('[%.2f cm,  %.2f cm]\n', limita_inf, limita_sup);

%------------------------------------------------------------------------------------------------

% CERINTA 8: TESTAREA IPOTEZELOR STATISTICE

% Motivatie: Intervalele de incredere ne-au dat un raspuns probabilistic, dar
% nu ne-au permis sa luam o decizie clara despre o ipoteza concreta. Testul
% statistic rezolva acest lucru: formulam explicit ipoteza ca inaltimea medie
% a jucatorilor de fotbal este 180 cm (valoare frecvent citata in literatura)
% si verificam daca datele o sustin sau o contrazic. Alegem testul t bilateral
% (ttest) deoarece nu stim a priori in ce directie ar putea devia media reala,
% iar dispersia populatiei nu este cunoscuta cu certitudine.

disp(' ');
disp('---------- Cerinta 8: Testarea ipotezelor statistice ----------')
disp(' ')
% Media de inaltime a jucatorilor este 180 cm.
% H0: mu = 180. H1: mu != 180 (Test bilateral)
mu0 = 180;
alpha_test = 0.05;

% Deoarece dispersia reala a populatiei este teoretic necunoscuta,
% folosim testul t (ttest)
[h, p_val, ci_test, stats] = ttest(populatie_inaltime, mu0, 'Alpha', alpha_test, 'Tail', 'both');

fprintf('Ipoteza nula (H0): Inaltimea medie a jucatorilor este de %d cm.\n', mu0);
fprintf('Statistica t: %.4f | P-value: %.4f\n', stats.tstat, p_val);

if h == 1 % if p_val < alpha_test --- Daca ipoteza este nula
    disp('Decizie: Respingem H0! Inaltimea medie a jucatorilor difera semnificativ de 180 cm');
else
    disp('Decizie: Nu respingem H0. Datele sugereaza ca inaltimea medie este in jur de 180 cm');
end

%------------------------------------------------------------------------------------------------

% CERINTA 9: ANALIZA CORELATIILOR

% Motivatie: Dupa ce am analizat fiecare variabila individual (cerinta 3),
% ne intereseaza acum relatiile dintre ele. Vrem sa verificam daca atributele
% fizice (inaltimea) influenteaza performanta (goluri, pase, minute jucate)
% sau daca acestea sunt independente. Includem si perechea goluri-pase pentru
% a vedea daca jucatorii care marcheaza mult si paseaza mult sunt aceeasi.
% Alegem Pearson deoarece variabilele sunt numerice continue si ne intereseaza
% asocierea liniara. Heatmap-ul face imediat vizibile corelatiile puternice
% (aproape de 1 sau -1) si cele neglijabile (aproape de 0), fara a fi nevoie
% sa citim o matrice de numere.

disp(' ');
disp('---------- Cerinta 9: Analiza corelatiilor ----------')
disp(' ')

% Construim o matrice cu variabilele de interes fizice si de performanta
Matrice_Date = [dateCurate.goals, dateCurate.assists, dateCurate.minutes_played, dateCurate.height];
Nume_Variabile = {'Goluri', 'Pase Decisive', 'Minute Jucate', 'Inaltime'};

% Calculam Matricea de Corelatie Pearson

Matrice_Corelatie = corr(Matrice_Date, 'Type', 'Pearson');

figure('Name', 'Cerinta 9: Matricea de Corelatie');
h_heat = heatmap(Nume_Variabile, Nume_Variabile, Matrice_Corelatie);
h_heat.Title = 'Matricea Coeficientilor de Corelatie Pearson';
h_heat.Colormap = parula; % setam paleta de culori
h_heat.ColorLimits = [-1 1]; % limite de la -1 la 1

disp('S-a generat Harta Termica (Heatmap) a corelatiilor.');
disp('Variabilele cu coeficientul cel mai apropiat de 1 sau -1 au cea mai mare influenta.');

% =======================================================
% CERINȚA 10: ÎNVĂȚARE AUTOMATĂ - kNN 
% Eticheta:   pozitia in teren (Forward / Midfielder / Defender)
% Predictori: goluri, pase decisive, cartonase galbene,
%             minute jucate, inaltime
% =======================================================
disp(' ');
disp('=======================================================');
disp('   INVATARE AUTOMATA - kNN (CERINTA 10)');
disp('=======================================================');

% -------------------------------------------------------
% PAS 1: Construirea etichetei de clasa
% -------------------------------------------------------
poz_str_ml = lower(cellstr(dateCurate.position));
clasa_ml   = repmat({'Other'}, height(dateCurate), 1);

clasa_ml(contains(poz_str_ml, {'forward','attacker','striker','winger'})) = {'Forward'};
clasa_ml(contains(poz_str_ml, {'midfielder','midfield'}))                  = {'Midfielder'};
clasa_ml(contains(poz_str_ml, {'defender','back','centre-back'}))          = {'Defender'};

% Eliminam inregistrarile necategorizabile
mask_valid = ~strcmp(clasa_ml, 'Other');
clasa_ml   = clasa_ml(mask_valid);
date_ml    = dateCurate(mask_valid, :);
Y_ml       = categorical(clasa_ml);

fprintf('Distributia claselor:\n');
disp(summary(Y_ml));

% -------------------------------------------------------
% PAS 2: Definirea predictorilor numerici
% kNN foloseste distanta Euclidiana direct pe valorile reale,
% fara a fi nevoie de discretizare (spre deosebire de Naive Bayes).
% Standardize=true: necesar deoarece variabilele au scale diferite
% (goluri: 0-50 vs minute: 90-3420) - fara standardizare, minutele
% ar domina distanta si ar distorsiona clasificarea.
% -------------------------------------------------------
X_num = date_ml{:, {'goals', 'assists', 'yellow_cards', 'minutes_played', 'height'}};

% -------------------------------------------------------
% PAS 3: Separarea datelor (70% antrenare, 30% testare)
% cvpartition cu HoldOut - exact ca in Lab 11
% -------------------------------------------------------
rng(42);
cv  = cvpartition(Y_ml, 'HoldOut', 0.3);
idx = cv.test;

XTrain = X_num(~idx, :);   YTrain = Y_ml(~idx);
XTest  = X_num( idx, :);   YTest  = Y_ml( idx);

fprintf('Set antrenare: %d exemple | Set testare: %d exemple\n\n', ...
    sum(~idx), sum(idx));

% -------------------------------------------------------
% PAS 4: Antrenare si evaluare kNN
% k=5: echilibru intre bias si varianta, standard in practica
% -------------------------------------------------------
disp('--- Antrenare model kNN (k=5) ---');
k = 5;
knnModel    = fitcknn(XTrain, YTrain, 'NumNeighbors', k, 'Standardize', true);
knnPred     = predict(knnModel, XTest);
knnAccuracy = sum(knnPred == YTest) / numel(YTest) * 100;
fprintf('Acuratete kNN (k=%d): %.2f%%\n\n', k, knnAccuracy);

% -------------------------------------------------------
% PAS 5: Vizualizari
% -------------------------------------------------------

% Matrice de confuzie
figure('Name', 'Cerinta 10 - Matrice Confuzie kNN', 'NumberTitle', 'off');
confusionchart(YTest, knnPred, ...
    'Title', sprintf('Matrice de confuzie - kNN k=%d (%.1f%%)', k, knnAccuracy), ...
    'RowSummary',    'row-normalized', ...
    'ColumnSummary', 'column-normalized');

fprintf('Interpretare:\n');
fprintf('  kNN identifica cei mai apropiati %d vecini ai unui jucator\n', k);
fprintf('  din setul de antrenare si atribuie clasa majoritara.\n');
fprintf('  Datele au fost standardizate pentru a evita dominarea\n');
fprintf('  distantei de catre variabile cu scale mari (minute jucate).\n');
fprintf('  Acuratete %.2f%% > 33%% (baseline random 3 clase).\n', knnAccuracy);