%% ƥ��ȱ���Ѱ���庯��
%���룺pieceDataSmooth(����ƽ��������)��templatePulse��ƥ��ģ�壩��pulseMatchDegreeThreshold��ƥ�����ֵ����peakOfsampleRatePiece�������峤�ȣ�
%�����matchPeakIndex�������ֵλ�ã�
function matchPeakIndexSave = findPulse(pieceDataSmooth,templatePulse,pulseMatchDegreeThreshold,peakOfsampleRatePiece)
    matchPeakIndexSave = [];%�洢ƥ���ֵλ��
    matchDegreeSave = [];%�洢���������ƥ���
    matchDegreeLength = length(pieceDataSmooth)-peakOfsampleRatePiece*2;%��������
    
    %�����ȥһ�����峤�ȵ�������ʲô����������������
    %������ƥ��ȣ�����ݴ浽matchDegreeSave��
    for idxMatch = 1:matchDegreeLength
        dataForMatch = pieceDataSmooth(idxMatch:idxMatch+peakOfsampleRatePiece*2);
        matchDegree = pulseMatching(dataForMatch,templatePulse);
        matchDegreeSave = [matchDegreeSave;matchDegree];
    end
%     figure(2)
%     plot(matchDegreeSave);
    %��matchDegreeSave��Ѱ��ƥ��ȴ�����ֵ�ĵ㣬��¼λ��
    matchDegreeIndex = [];%�洢matchDegreeSave��ƥ��ȴ�����ֵ��λ��
    for idx = 1:matchDegreeLength
        if matchDegreeSave(idx) > pulseMatchDegreeThreshold
            matchDegreeIndex = [matchDegreeIndex,idx];%%��ƽ�������з���ƥ��ȵĵ�λ��
        end
    end
    if isempty(matchDegreeIndex)%%isempty��A�����ж�����A�Ƿ�Ϊ�ա�
        return
    else
        %��MatchDegreeIndex�ֳ�������
        matchIndexStart = matchDegreeIndex(1);
        matchIndexEnd = [];
        for idx = 2:length(matchDegreeIndex)
            if matchDegreeIndex(idx)-matchDegreeIndex(idx-1)~=1  %%%% ~=Ϊ�����ڵ���˼ 
                
                %Ϊɶ�ǲ�����1�������ҵ�һ��������smooth������ݣ����Ǹ���ά���飬ǰ����ȡ������ʲô�����������������������
                %%��ƽ�����߷���ƥ��ȵĵ��У�ȷ������ֹλ��
                matchIndexStart = [matchIndexStart,matchDegreeIndex(idx)];
                matchIndexEnd = [matchIndexEnd,matchDegreeIndex(idx-1)];
            end
        end
        matchIndexEnd = [matchIndexEnd,matchDegreeIndex(end)];
        %�ֱ�õ�ÿ��MatchDegreeIndex��ƥ��ȷ�ֵλ��
        for idxPeak = 1:length(matchIndexStart)
            [~,matchPeakIndex] = max( matchDegreeSave(matchIndexStart(idxPeak):matchIndexEnd(idxPeak)));%%�ڷ���ƥ��ȵ�ƽ�����ݶ���ȡ���㣬���Ƿ�ֵ�㣬ȡ������������е�����
            matchPeakIndexSave =[matchPeakIndexSave, matchIndexStart(idxPeak)+matchPeakIndex-1];%��������ݵ���ʼλ�ü�������-1�õ���ֵ����������ʼ��λ��
        end
        %��������ࣺ����ֵ�������һ��������,���Ա����ֵ�����Ķ���
        %��һ����Ҫʦ�ֽ���һ�£�������������������������������������������������������������
        endNum = length(matchPeakIndexSave);%��ֵλ�õĸ���
        idxNum = 2;%�ӵڶ����忪ʼ������ǰһ����ļ��
        while idxNum <= endNum
            if (matchPeakIndexSave(idxNum)-matchPeakIndexSave(idxNum-1)<2*peakOfsampleRatePiece)
                %%�ж��������������ֵ����Ƿ����һ��������
                if(matchDegreeSave(matchPeakIndexSave(idxNum),1)>matchDegreeSave(matchPeakIndexSave(idxNum-1),1))
                    matchPeakIndexSave(idxNum-1) = [] ;%%���������ֵ��࣬��С�������ȣ����������ֵ�ص���Ӧ��Ϊһ����ֵ��
                else
                    matchPeakIndexSave(idxNum) = [] ;%%���������ֵ��࣬��С�������ȣ����������ֵ�ص���Ӧ��Ϊһ����ֵ��
                end
                endNum = endNum-1;
            else
                idxNum = idxNum+1;
            end
        end
        %�����ֵλ��
        matchPeakIndexSave = (matchPeakIndexSave+peakOfsampleRatePiece)';
        %��ֵ������������λ�á���ֵ����ʵλ��
    end
end
% % % Ƶ������಻ͬƵ�ʵļ��ϣ��γ�һ���ܿ��copyƵ�ʷ�Χ����ͬ��Ƶ����������ܲ�ͬ������ͬƵ�ʵ������ߵ����ٽ������γɵ����߶ȣ��ͽ�Ƶ�װ����ߡ�
% % % �е���˼�ǽ��ޣ�����ֵ�ֽ��ٽ�ֵ����ָһ��ЧӦ�ܹ����������ֵ�����ֵ��
% % % ���峤�������������ʼ��ʱ���źţ������������ʱ���źš���ʼ������һ�����˶೤ʱ�䣬������õ�ʱ�䣬�������峤�ȡ� 