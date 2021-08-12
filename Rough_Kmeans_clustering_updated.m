clc
close all
clear

%load image
I = im2double(imresize(imread('four.jpg'),[200 200]));
% imshow(I);
CF = reshape(I,size(I, 1)*size(I, 2), 3);         %1st_col=R, 2nd_col=G, 3rd_col=B
% disp(F);
K = input('Input no of cluster : ');              %take CLUSTERS no.
% fprintf('No of cluster = %d\n', K);
CENTS = CF(ceil(rand(K, 1)*size(CF, 1)),:);         %random centre genarate
c = 0;
for i=1:K                                           %cheack single color image or not
    if CENTS(1,:)== CENTS(i,:)
        c = c + 1;
    end
end
% disp(CENTS);
if c == K
    disp('You enter single color image');
else
    TH = input('Input the thresold point : ');        %take thresold point
    
    weight1 = rand(1);                                %genarate Wupper and Wlower
    weight2 = 1 - weight1;
    
    if weight1>weight2
        Wlower = weight1;
        Wupper = weight2;
    else
        Wupper = weight1;
        Wlower = weight2;
    end
    
    fprintf('Wlower = %.4f\n',Wlower);
    fprintf('wupper = %.4f\n',Wupper);

    NCNT = zeros(K,3);
    OCNT = CENTS;
    count = 0;

    while OCNT~=NCNT
        count = count + 1;
%         disp(count);
        if count == 100
            break;
        end
        OCNT = NCNT;
        DIF = zeros(size(CF, 1), K+2);                    %initial matrix with distances and labels
        for i = 1:size(CF,1)
          for j = 1:K  
            DIF(i,j) = norm(CF(i,:) - CENTS(j,:));        %distance from each centre
          end
          [Distance, CN] = min(DIF(i,1:K));               % 1:K are Distance from Cluster Centers 1:K 
          DIF(i,K+1) = CN;                                % K+1 is Cluster Label
          DIF(i,K+2) = Distance;                          % K+2 is Minimum Distance
        end

        DIV = zeros(size(CF, 1), K);
        for i = 1:size(CF,1)
            for j = 1:K
                DIV(i,j) = DIF(i,K+2)/DIF(i,j);           %min value devide by all value
            end
        end

        KL = zeros(K,size(CF,1),3);                       %genarate lower approximation
        KU = zeros(K,size(CF,1),3);                       %genarate upper approximation
        for i = 1:size(CF,1)
            for j = 1:K
                if DIV(i,j)>=TH
                    k1 = j;
                    k2 = DIF(i,K+1);
                    KU(k1,i,:) = CF(i,:);
                    KU(k2,i,:) = CF(i,:);
                else
                    k = DIF(i,K+1);
                    KL(k,i,:) = CF(i,:);
                    KU(k,i,:) = CF(i,:);
                end
            end
        end

        for k = 1:K
            SL = sum(KL(k,:,:));
            LA = [SL(:,:,1)/nnz(KL(k,:,1)) SL(:,:,2)/nnz(KL(k,:,2)) SL(:,:,3)/nnz(KL(k,:,3))];
            SL = sum(KL(k,:));
            UML = KU(k,:,:) - KL(k,:,:);
            SUML = sum(UML(1,:,:));
            UA = [SUML(:,:,1)/nnz(UML(1,:,1)) SUML(:,:,2)/nnz(UML(1,:,2)) SUML(:,:,3)/nnz(UML(1,:,3))];
            SUML = sum(UML(1,:));
            if SL~=0 && SUML ~= 0                             %new centre genarate
    %             disp('condition1');
                SM = (Wlower*LA + Wupper*UA);
                NCNT(k,:) = SM(1,:);
            else
                if SL ~= 0 && SUML == 0
    %                 disp('condition2');
                    NCNT(k,:) = LA(1,:);
                else
    %                 disp('condition3');
                    NCNT(k,:) = UA(1,:);
                end
            end
        end
        CENTS = NCNT;
    end

    X = zeros(size(CF,1),3);
    for i = 1:K
    idx = find(DIF(:,K+1) == i);
    X(idx,:) = repmat(CENTS(i,:),size(idx,1),1); 
    end
    T = reshape(X,size(I,1),size(I,2),3);
    figure()
    subplot(121); imshow(I); title('original image')
    subplot(122); imshow(T); title('segmented image')
%     imwrite(I,'original.jpg');
%     imwrite(T,'segmented.jpg');
end

