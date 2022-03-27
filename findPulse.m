%% 匹配度遍历寻脉冲函数
%输入：pieceDataSmooth(包络平滑后数据)、templatePulse（匹配模板）、pulseMatchDegreeThreshold（匹配度阈值）、peakOfsampleRatePiece（半脉冲长度）
%输出：matchPeakIndex（脉冲峰值位置）
function matchPeakIndexSave = findPulse(pieceDataSmooth,templatePulse,pulseMatchDegreeThreshold,peakOfsampleRatePiece)
    matchPeakIndexSave = [];%存储匹配峰值位置
    matchDegreeSave = [];%存储遍历计算的匹配度
    matchDegreeLength = length(pieceDataSmooth)-peakOfsampleRatePiece*2;%遍历次数
    
    %这里减去一个脉冲长度的意义是什么？？？？？？？？
    %逐点计算匹配度，结果暂存到matchDegreeSave中
    for idxMatch = 1:matchDegreeLength
        dataForMatch = pieceDataSmooth(idxMatch:idxMatch+peakOfsampleRatePiece*2);
        matchDegree = pulseMatching(dataForMatch,templatePulse);
        matchDegreeSave = [matchDegreeSave;matchDegree];
    end
%     figure(2)
%     plot(matchDegreeSave);
    %在matchDegreeSave中寻找匹配度大于阈值的点，记录位置
    matchDegreeIndex = [];%存储matchDegreeSave中匹配度大于阈值的位置
    for idx = 1:matchDegreeLength
        if matchDegreeSave(idx) > pulseMatchDegreeThreshold
            matchDegreeIndex = [matchDegreeIndex,idx];%%在平滑曲线中符合匹配度的点位置
        end
    end
    if isempty(matchDegreeIndex)%%isempty（A）：判断数列A是否为空。
        return
    else
        %将MatchDegreeIndex分成连续段
        matchIndexStart = matchDegreeIndex(1);
        matchIndexEnd = [];
        for idx = 2:length(matchDegreeIndex)
            if matchDegreeIndex(idx)-matchDegreeIndex(idx-1)~=1  %%%% ~=为不等于的意思 
                
                %为啥是不等于1，，而且第一个参数是smooth后的数据，即是个二维数组，前面求取长度是什么个情况？？？？？？？？？
                %%在平滑曲线符合匹配度的点中，确定其起止位置
                matchIndexStart = [matchIndexStart,matchDegreeIndex(idx)];
                matchIndexEnd = [matchIndexEnd,matchDegreeIndex(idx-1)];
            end
        end
        matchIndexEnd = [matchIndexEnd,matchDegreeIndex(end)];
        %分别得到每段MatchDegreeIndex中匹配度峰值位置
        for idxPeak = 1:length(matchIndexStart)
            [~,matchPeakIndex] = max( matchDegreeSave(matchIndexStart(idxPeak):matchIndexEnd(idxPeak)));%%在符合匹配度的平滑数据段中取最大点，就是峰值点，取其在这段数据中的序列
            matchPeakIndexSave =[matchPeakIndexSave, matchIndexStart(idxPeak)+matchPeakIndex-1];%在这段数据的起始位置加上序列-1得到峰值所在脉冲起始的位置
        end
        %检查脉冲间距：两峰值间隔大于一个脉冲宽度,用以避免峰值附近的抖动
        %这一段需要师兄解释一下？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？
        endNum = length(matchPeakIndexSave);%峰值位置的个数
        idxNum = 2;%从第二个峰开始，检查和前一个峰的间距
        while idxNum <= endNum
            if (matchPeakIndexSave(idxNum)-matchPeakIndexSave(idxNum-1)<2*peakOfsampleRatePiece)
                %%判断两个连续脉冲峰值间距是否大于一个脉冲间距
                if(matchDegreeSave(matchPeakIndexSave(idxNum),1)>matchDegreeSave(matchPeakIndexSave(idxNum-1),1))
                    matchPeakIndexSave(idxNum-1) = [] ;%%检查两个峰值间距，若小于脉冲宽度，则该两个峰值重叠，应化为一个峰值。
                else
                    matchPeakIndexSave(idxNum) = [] ;%%检查两个峰值间距，若小于脉冲宽度，则该两个峰值重叠，应化为一个峰值。
                end
                endNum = endNum-1;
            else
                idxNum = idxNum+1;
            end
        end
        %输出峰值位置
        matchPeakIndexSave = (matchPeakIndexSave+peakOfsampleRatePiece)';
        %峰值所在脉冲起点的位置—峰值的真实位置
    end
end
% % % 频谱是许多不同频率的集合，形成一个很宽的copy频率范围；不同的频率其振幅可能不同。将不同频率的振幅最高点连百结起来形成的曲线度，就叫频谱包络线。
% % % 阈的意思是界限，故阈值又叫临界值，是指一个效应能够产生的最低值或最高值。
% % % 脉冲长度是脉冲产生开始的时间信号，到脉冲结束的时间信号。开始到结束一共用了多长时间，这个所用的时间，就是脉冲长度。 