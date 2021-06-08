function find_trains_by_maxima(T_, sig, x_a_, a_, tres)
    global treshold T x_a cor1 cor2 a tmp
    treshold = tres;
    T = T_;
    x_a = x_a_;
    a = a_;
    dat = load('patterns/corr_types/type1.mat', 'T1', 'sig1');
    cor1 = dat.sig1;
    dat = load('patterns/corr_types/type2.mat', 'T2', 'sig2');
    cor2 = dat.sig2;
    tmp = 0;
    
    disp('stage 1');
    inters = make_intervals(a);
    disp(' ');
    disp('stage 2');
    inters = analise_intervals(inters);
    
    hold on;
    plot(T,sig);
    
    yyaxis right
    plot(x_a, a);
    ylim([-0.86 0.8])
    ylabel('"Envelope" function')
    yyaxis left
    %plot([min(x_a), max(x_a)], [treshold, treshold]);
    good = 0;
    for i = 1:length(inters)
        plot(x_a(inters(i).begin : inters(i).end), sig(inters(i).b_T : inters(i).e_T), inters(i).color);
        if ~isempty(inters(i).text)
            plot(x_a(inters(i).b_a : inters(i).e_a), sig(a2T(inters(i).b_a) : a2T(inters(i).e_a)), inters(i).color2);
            text(x_a(inters(i).b_a), 20, inters(i).text)
            good = good + 1;
        end
    end
    xlim([4000 4550])
    xlabel('Time (sec)')
    ylabel('Velocity (mkm/sec)')
    disp(good);
    disp(tmp);
end

function [ind, mask] = pos_max(x)
    xd = diff(x); 
    xds = sign(xd); 
    ix = (xds(1:end-1)~=xds(2:end)); % all extrema 
    ix = ix & (xds(1:end-1)>0); % only maximums 
    mask(2:length(ix)+1) = ix; 
    ind = find(mask); 
end

function [ind, mask] = pos_min(x)
    xd = diff(x); 
    xds = sign(xd); 
    ix = (xds(1:end-1)~=xds(2:end)); % all extrema 
    ix = ix & (xds(1:end-1)<0); % only minimums
    mask(2:length(ix)+1) = ix; 
    ind = find(mask); 
end

function analise_ind(x_max, y_max, x_min, y_min)
    global treshold
    for i = 1:length(x_max)
        if y_max(i)>treshold
            plot(x_max(i),y_max(i), 'og')
        end
    end
end

function intervals = make_intervals(a)
    global treshold
    intervals = struct.empty;
    
    up = true;
    nchar = 0;
    for i = 2:length(a)
        if rem(i, 100) == 0
            fprintf(repmat('\b', 1, nchar));
            nchar = fprintf('%1.3f', i./length(a)*100);
        end
        if up
            if (a(i-1) < treshold) && (a(i) > treshold)
                intervals(length(intervals) + 1).begin = i;
                intervals(end).b_T = a2T(i);
                up = false;
            end
        else
            if a(i-1) > treshold && (a(i) < treshold || i == length(a))
                intervals(end).end = i-1;
                intervals(end).e_T = a2T(i-1);
                up = true;
            end
        end
    end
end

function inters = analise_intervals(inters)
    global x_a cor1 cor2 a tmp
    
    nchar = 0;
    for i = 1:length(inters)
        
        if rem(i, 1) == 0
            fprintf(repmat('\b', 1, nchar));
            nchar = fprintf('%1.3f', i./length(inters)*100);
        end
        
        len = x_a(inters(i).end) - x_a(inters(i).begin);
        inters(i).len = len;
        if len > 40 && len < 700
            inters(i).color = 'g';
            tmp = tmp + 1;
            if inters(i).begin-1000 > 0 && inters(i).end+1000 < length(a)
                r1 = mcorr(a(inters(i).begin-1000 : inters(i).end+1000), cor1);
                r2 = mcorr(a(inters(i).begin-1000 : inters(i).end+1000), cor2);
                [mr1,xr1] = max(r1);
                [mr2,xr2] = max(r2);
                if max(mr1,mr2) > 0.9
                    if mr1>mr2
                        inters(i).text = sprintf('Type 1: %0.2f(%0.2f)', mr1, mr2);
                        inters(i).b_a = inters(i).begin + xr1 - 1000;
                        inters(i).e_a = inters(i).begin + xr1 - 1000 + length(cor1);
                        inters(i).color2 = 'm';
                    else
                        inters(i).text = sprintf('Type 2: %0.2f(%0.2f)', mr2, mr1);
                        inters(i).b_a = inters(i).begin + xr2 - 1000;
                        inters(i).e_a = inters(i).begin + xr2 - 1000 + length(cor2);
                        inters(i).color2 = 'c';
                    end
                else
                    inters(i).color = 'r';
                end
            end
        else
            inters(i).color = 'r';
        end
    end
end

function a = a2T(ind)
    global T x_a
    a = find(T - x_a(ind) == 0);
end

function a = mcorr(A, B)
    lA = length(A);
    lB = length(B);
    a = zeros(1, lA-lB);
    
    for i = 1:(lA-lB)
        c = corrcoef(A(i:i+lB-1), B);
        a(i) = c(2,1);
    end
end

function a = mcorr_fft(A, B)
    templ = [flip(B) zeros(1, length(A) - length(B))];
    a = ifft( fft(A) .* conj(fft(templ)) );
end