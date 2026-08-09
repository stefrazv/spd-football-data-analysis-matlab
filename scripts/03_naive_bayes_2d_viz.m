%in caz ca da eroare la run: cd('E:\spd\proiect_serios_spd')

% =======================================================
% CERINȚA 2: IMPORTAREA ȘI PREPROCESAREA DATELOR
% =======================================================

% NOTĂ: Codul de mai jos (joncțiunea) a fost utilizat pentru generarea 
% setului de date final. Pentru predare, am comentat procesarea brută 
% și încărcăm direct fișierul rezultat 'set_date_fotbal_final.csv'.


disp('Se citesc datele brute...');
performante = readtable('player_performances.csv');
profil_jucatori = readtable('player_profiles.csv');

disp('Se realizează joncțiunea tabelelor...');
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
disp('Gata! Fisierul "set_date_fotbal_final.csv" a fost generat.');


% --- ÎNCĂRCARE DIRECTĂ PENTRU PREZENTARE ---
disp('Se incarca setul de date final prelucrat...');
dateCurate = readtable('set_date_fotbal_final.csv');

% Obligatoriu: Convertim coloana text inapoi in categorica
dateCurate.position = categorical(dateCurate.position);

% Afișăm sumarul pentru confirmare
summary(dateCurate);

% =======================================================
% CERINȚA 3: PREZENTAREA PARAMETRILOR STATISTICI CHEIE
% =======================================================
disp(' ');
disp('=======================================================');
disp('   ANALIZA STATISTICA DESCRIPTIVA (CERINTA 3)');
disp('=======================================================');

% Extragem variabilele de interes
goluri = dateCurate.goals;
pase = dateCurate.assists;
inaltime = dateCurate.height;

% -------------------------------------------------------
% 1. Analiza pentru GOLURI
% -------------------------------------------------------
disp('--- 1. Parametri statistici pentru GOLURI ---');
fprintf('Media: %.2f goluri pe sezon\n', mean(goluri));
fprintf('Mediana: %.0f goluri (Jucatorul "din mijloc")\n', median(goluri));
fprintf('Modulul: %.0f goluri (Cea mai frecventa valoare)\n', mode(goluri));
fprintf('Abaterea standard: %.2f\n', std(goluri));
fprintf('Amplitudinea (Range): %.0f\n', max(goluri) - min(goluri));
fprintf('Interval intercuartilic (IQR): %.0f\n\n', iqr(goluri));

% -------------------------------------------------------
% 2. Analiza pentru PASE DECISIVE (Assists)
% -------------------------------------------------------
disp('--- 2. Parametri statistici pentru PASE DECISIVE ---');
fprintf('Media: %.2f pase pe sezon\n', mean(pase));
fprintf('Mediana: %.0f pase\n', median(pase));
fprintf('Modulul: %.0f pase\n', mode(pase));
fprintf('Abaterea standard: %.2f\n', std(pase));
fprintf('Amplitudinea (Range): %.0f\n', max(pase) - min(pase));
fprintf('Interval intercuartilic (IQR): %.0f\n\n', iqr(pase));

% -------------------------------------------------------
% 3. Analiza pentru INALTIME (Height)
% -------------------------------------------------------
disp('--- 3. Parametri statistici pentru INALTIME ---');
fprintf('Media: %.1f cm\n', mean(inaltime));
fprintf('Mediana: %.0f cm\n', median(inaltime));
fprintf('Modulul: %.0f cm\n', mode(inaltime));
fprintf('Abaterea standard: %.2f cm\n', std(inaltime));
fprintf('Amplitudinea (Range): %.0f cm\n', max(inaltime) - min(inaltime));
fprintf('Interval intercuartilic (IQR): %.0f cm\n\n', iqr(inaltime));
%---------------------------------------------------------------------------------
% =======================================================
% CERINȚA 4: DIAGRAMA BOXPLOT ȘI DETECȚIA VALORILOR ABERANTE
% =======================================================
disp(' ');
disp('=======================================================');
disp('   ANALIZA VIZUALA SI OUTLIERS (CERINTA 4)');
disp('=======================================================');

% 1. Calculul cuartilelor folosind functia de baza quantile
% Q1 reprezintă valoarea sub care se află 25% din date, iar Q3 pentru 75%
Q_calc = quantile(goluri, [0.25, 0.75]);
Q1 = Q_calc(1);
Q3 = Q_calc(2);

% 2. Calculul limitelor pentru valorile aberante (Metoda 1.5 * IQR din Lab 6)
% Folosim iqr-ul calculat la cerinta anterioara (sau Q3 - Q1)
iqr_B = Q3 - Q1; 
lim_inf = Q1 - 1.5 * iqr_B;
lim_sup = Q3 + 1.5 * iqr_B;

% 3. Extragerea valorilor aberante (Outliers) din sirul de goluri
% Ne interesează jucătorii de elită (care depășesc limita superioară)
outliers_goluri = goluri(goluri > lim_sup);
nr_outliers = length(outliers_goluri);

fprintf('Cuartila inferioara (Q1): %.0f\n', Q1);
fprintf('Cuartila superioara (Q3): %.0f\n', Q3);
fprintf('Limita superioara pt outliers (Q3 + 1.5 * IQR): %.2f\n', lim_sup);
fprintf('Am gasit %d atacanți de elita (valori aberante peste %.2f goluri)!\n', nr_outliers, lim_sup);

% 4. Reprezentarea grafică (Diagrama Boxplot)
% Aceasta permite diagnosticarea vizuală a asimetriei distribuției
figure; 
boxplot(dateCurate.goals, cellstr(dateCurate.position));

% Estetica graficului
title('Distributia Golurilor pe Pozitii in Teren (Detectia Outliers)');
xlabel('Pozitia Jucatorului');
ylabel('Numar de Goluri Marcate');
grid on;


% =======================================================
% CERINȚA 5: TEOREMA DE LIMITĂ CENTRALĂ (Laboratorul 7)
% =======================================================
disp(' ');
disp('=======================================================');
disp('   TEOREMA DE LIMITA CENTRALA (CERINTA 5)');
disp('=======================================================');
% Alegem o variabilă numerică puternic asimetrică (Golurile) pentru a 
% demonstra vizual puterea teoremei.
populatie_goluri = dateCurate.goals;

figure('Name', 'Cerinta 5: Teorema de Limita Centrala');
subplot(1, 2, 1);
histogram(populatie_goluri, 'FaceColor', '#0072BD');
title('Distributia Originala a Golurilor');
xlabel('Goluri'); ylabel('Frecventa');

% Extragem m eșantioane și calculăm media fiecăruia
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

% =======================================================
% CERINȚA 6: ESTIMAREA UNUI PARAMETRU STATISTIC (Lab 7)
% =======================================================
disp(' ');
disp('=======================================================');
disp('   ESTIMARE PUNCTUALA (CERINTA 6)');
disp('=======================================================');
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

% =======================================================
% CERINȚA 7: ESTIMAREA PRIN INTERVALE DE ÎNCREDERE (Lab 8)
% =======================================================
disp(' ');
disp('=======================================================');
disp('   INTERVALE DE INCREDERE (CERINTA 7)');
disp('=======================================================');
% Folosim un coeficient de incredere de 95% (alfa = 0.05)
alfa = 0.05; 
z_alfa_2 = norminv(1 - alfa/2); % valoare din tabel Z

% Eroarea se calculeaza folosind formula din curs
eroare = z_alfa_2 * (abatere_estimata / sqrt(n_est));

limita_inf = medie_estimata - eroare;
limita_sup = medie_estimata + eroare;

fprintf('Cu o certitudine de 95%%, media reala a inaltimii jucatorilor se afla in intervalul:\n');
fprintf('[%.2f cm,  %.2f cm]\n', limita_inf, limita_sup);

% =======================================================
% CERINȚA 8: TESTAREA IPOTEZELOR STATISTICE (Lab 9)
% =======================================================
disp(' ');
disp('=======================================================');
disp('   TESTAREA IPOTEZELOR (CERINTA 8)');
disp('=======================================================');
% Suspectam ca media de inaltime a jucatorilor este 180 cm.
% H0: mu = 180. H1: mu != 180 (Test bilateral)
mu0 = 180;
alpha_test = 0.05;

% Deoarece dispersia reala a populatiei este teoretic necunoscuta,
% folosim testul t (ttest)
[h, p_val, ci_test, stats] = ttest(populatie_inaltime, mu0, 'Alpha', alpha_test, 'Tail', 'both');

fprintf('Ipoteza nula (H0): Inaltimea medie a jucatorilor este de %d cm.\n', mu0);
fprintf('Statistica t: %.4f | P-value: %.4f\n', stats.tstat, p_val);

if h == 1
    disp('Decizie: Respingem H0! Inaltimea medie a jucatorilor difera semnificativ de 180 cm.');
else
    disp('Decizie: Nu respingem H0. Datele sugereaza ca inaltimea medie este in jur de 180 cm.');
end

% =======================================================
% CERINȚA 9: ANALIZA CORELAȚIILOR (Lab 10)
% =======================================================
disp(' ');
disp('=======================================================');
disp('   ANALIZA CORELATIILOR (CERINTA 9)');
disp('=======================================================');
% Construim o matrice cu variabilele de interes fizice si de performanta
Matrice_Date = [dateCurate.goals, dateCurate.assists, dateCurate.minutes_played, dateCurate.height];
Nume_Variabile = {'Goluri', 'Pase_Decisive', 'Minute_Jucate', 'Inaltime'};

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
% CERINȚA 10 (Varianta 2D): NAIVE BAYES CU VIZUALIZARE DUALĂ
% Predictori: goals, assists (numeric pentru grafic)
% =======================================================
disp(' ');
disp('=======================================================');
disp('   INVATARE AUTOMATA 2D - VIZUALIZARE DATE ȘI REGIUNI');
disp('=======================================================');

% 1. Pregătirea datelor (Gruparea pozițiilor pentru a avea 3 clase)
poz_str_ml = lower(cellstr(dateCurate.position));
clasa_ml = repmat({'Other'}, height(dateCurate), 1);
clasa_ml(contains(poz_str_ml, {'forward','attacker','striker','winger'})) = {'Forward'};
clasa_ml(contains(poz_str_ml, {'midfielder','midfield'})) = {'Midfielder'};
clasa_ml(contains(poz_str_ml, {'defender','back','centre-back'})) = {'Defender'};

mask_valid = ~strcmp(clasa_ml, 'Other');
clasa_ml = clasa_ml(mask_valid);
date_2d = dateCurate(mask_valid, :);
Y_2d = categorical(clasa_ml);

% 2. Selectarea celor 2 predictori (NUMERICI pentru plot)
X_2d = [date_2d.goals, date_2d.assists]; 

% 3. Separarea datelor (70% antrenare, 30% testare)
rng(42); % pentru reproductibilitate
cv = cvpartition(Y_2d, 'HoldOut', 0.3);
idx = cv.test;
XTrain_2d = X_2d(~idx, :); YTrain_2d = Y_2d(~idx);
XTest_2d  = X_2d(idx, :);  YTest_2d  = Y_2d(idx);

% 4. Antrenare model Naive Bayes
nbModel_2d = fitcnb(XTrain_2d, YTrain_2d);

% 5. Testare și Acuratețe
nbPred_2d = predict(nbModel_2d, XTest_2d);
nbAcc_2d = sum(nbPred_2d == YTest_2d) / numel(YTest_2d) * 100;
fprintf('Acuratete Naive Bayes (2 predictori): %.2f%%\n', nbAcc_2d);

% 6. VIZUALIZARE GRAFIC 1: Clasificarea datelor de antrenare (ca în poza ta)
figure('Name', 'Clasificarea jucatorilor dupa performanta');
gscatter(XTrain_2d(:,1), XTrain_2d(:,2), YTrain_2d);
xlabel('Goluri marcate');
ylabel('Pase decisive (Assists)');
title('Clasificarea initiala a jucatorilor pe pozitii (Date Antrenare)');
grid on;

% 7. VIZUALIZARE GRAFIC 2: Harta regiunilor de decizie
% Aceasta folosește funcția plotDecisionBoundary.m care ar trebui să fie în folder.
figure('Name', 'Regiuni de decizie Naive Bayes');
plotDecisionBoundary(XTrain_2d, YTrain_2d, nbModel_2d);

% Ajustăm etichetele special pentru datele noastre
xlabel('Goluri marcate');
ylabel('Pase decisive (Assists)');
title(sprintf('Harta de Decizie Naive Bayes (Acuratete: %.1f%%)', nbAcc_2d));
