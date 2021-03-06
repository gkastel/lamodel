close all

nruns = 10
itvls = [60, 90,120, 150, 180]
pops = zeros(2, length(itvls), nruns)


for run = 1:10
    for d = 1:length(itvls)
        itvl = itvls(d)
        fn=sprintf('N100.B40.I10.i6.P2.p1.T%d.S%d.w2c', itvl, 1980+run-1)
                
        stimduration = 2000;
        
        ar = sscanf(fn, 'N%d.B40.I10.i6.P%d.p1.T%d.S%d.w%d');

        nneurons = ar(1);
        npatterns = ar(2);
        interval = ar(3);
        seed = ar(4);
        weakmem = ar(5);
        npyrs = nneurons*0.8;

        ff = sprintf('./data/%s/spikes.dat', fn);
        f = fopen(ff);
        t = fgets(f);
        raster = zeros(nneurons, stimduration*npatterns*2);
        nid = 1;
        while (ischar(t))
           times = str2num(t);
           raster(nid, times) = 1;
           t = fgets(f);
           nid=nid+1;
        end
        fclose(f)

        %figure()
        %imagesc(raster)

        trainingspikes = zeros(npyrs, npatterns);
        recallspikes = zeros(npyrs, npatterns);

        for n=1:npyrs
            for j=1:npatterns
                tstart = (j-1)*stimduration;
                tend = tstart + stimduration;
                trainingspikes(n,j) = sum(raster(n, tstart+1:tend));

                tstart = npatterns*stimduration + (j-1)*stimduration;
                tend = tstart + stimduration;
                recallspikes(n,j) = sum(raster(n, tstart+1:tend));
            end
        end

        pop = sum(recallspikes > 20)/npyrs;

        ff = sprintf('./data/%s/synstate.dat', fn);
        ss = load(ff);
        for n=1:npatterns
            sb = ss(find(ss(:,5)==n & ss(:,7) > 1.4) , 2); % branch ids array
            sun = unique(sb);
            zz = [];
            for k=1:length(sun)
                zz(end+1) = length(find(sb(:) == sun(k)));
            end
        end

    
        pops(:, d, run) = pop'
        
    end
end

figure()
title('Strong before weak')
pops = pops*100.0
mpop = mean(pops, 3)
stdpop = std(pops, 0, 3)
errorbar(mpop', stdpop')
xlabel('Interval between memories (minutes)')
ylabel('% of recruited pyramidal neurons')
legend('Strong memory', 'Weak memory');
set(gca, 'XTick',[1:length(itvls)]);
set(gca, 'XTickLabel',itvls);
saveas(gcf, 'w_s_s.eps')

