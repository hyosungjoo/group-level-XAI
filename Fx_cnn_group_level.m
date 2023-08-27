% Fx_cnn_group_level() - group-level analysis based on compact CNN
%               only clustering and selection process are included

% Input: 
%   STUDY        - a blank EEGLAB STUDY
%   ALLEEG       - a blank EEGLAB ALLEEG
%   feature      - feature array except with dipole location (NXM 2-D array)
%                 => N denotes number of convolutional filters (our data: 800)
%                 => M denotes number of features except with dipole location (our data: 3)
%   weight       - weight for clustering process (1-D array, our data: 2)
%                 => [feature except with dipole location, dipole location]
%   draw_figures - flag for drawing figures (0: off, 1: on)
%                 => sequentially figure1: task relevancy figure, figure2:dipoledistribution
%   data_path    - path which includes data

% Outputs:
%   STUDY        - a new STUDY set containing some or all of the datasets in ALLEEG, 
%                 plus additional information from the optional inputs above. 
%   ALLEEG       - a vector of EEG datasets included in the STUDY structure 

% This file is based on EEGLAB, see http://www.eeglab.org
% for the documentation and details.

% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
% THE POSSIBILITY OF SUCH DAMAGE.


function [STUDY, ALLEEG]= Fx_cnn_group_level(STUDY, ALLEEG, feature, weights, draw_figures, data_path)
    
    %% 1) make study
    % make a study
    eeg_path=[data_path, 'eeg_dipfit\'];
    list = cellstr(ls([eeg_path,'*.set']));
    EEG = pop_loadset('filename',list,'filepath',eeg_path);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'study',0);
    [STUDY ALLEEG] = std_editset( STUDY, ALLEEG, 'name','group-level','commands',{{'inbrain','on','dipselect',0.15}},'updatedat','on','savedat','on','rmclust','on' );
    [STUDY ALLEEG] = std_checkset(STUDY, ALLEEG);
    CURRENTSTUDY = 1; EEG = ALLEEG; CURRENTSET = [1:length(EEG)];
    
    num_sub=length(ALLEEG);
    num_branches=size(ALLEEG(1).icawinv,2);
    data_descripter=[repelem(1:num_sub,num_branches); repmat(1:num_branches,1, num_sub)]';
    
    %% 2) clustering
    rej_idx=zeros(num_sub*num_branches, 1);
    dip_arr=zeros(num_sub*num_branches, 3);
    for eeg_cnt=1:length(ALLEEG)
        eeg_sidx=(eeg_cnt-1)*num_branches+1;
        eeg_fidx=(eeg_cnt)*num_branches;

        dip_arr(eeg_sidx:eeg_fidx,:)=reshape([ALLEEG(eeg_cnt).dipfit.model.posxyz],[3,num_branches])';
        rej_temp=eeg_sidx+STUDY.datasetinfo(eeg_cnt).comps-1;
        rej_idx(rej_temp)=1;
    end

    % concatenate features
    feat_arr=[feature, dip_arr];
    feat_arr(~logical(rej_idx),:)=[];

    % normalize featuers
    norm_feat=(feat_arr-mean(feat_arr))./std(feat_arr);

    % set preclustering array
    [STUDY ALLEEG] = std_preclust(STUDY, ALLEEG, 1,{'spec','npca',size(feature,2),'weight',1,'freqrange',[3 25] },{'dipoles','weight',1});

    norm_feat(:,1:size(feature,2))=norm_feat(:,1:size(feature,2))*weights(1);
    norm_feat(:,size(feature,2)+1:end)=norm_feat(:,size(feature,2)+1:end)*weights(2);

    % normalize features
    STUDY.etc.preclust.preclustdata=norm_feat;

    % clustering
    clust_num=16;
    [STUDY] = pop_clust(STUDY, ALLEEG, 'algorithm','kmeans','clus_num',  clust_num, 'outliers',  3 );

    % get cluster info
    cluster_descripter=zeros(num_sub*num_branches, 1);

    cluster_subj_cell={STUDY.cluster.sets};
    cluster_comps_cell={STUDY.cluster.comps};
    for cluster_idx=3:length(cluster_subj_cell)

        % get cluster subj, comp arr
        cluster_subj_temp=cluster_subj_cell{cluster_idx};
        cluster_comps_temp=cluster_comps_cell{cluster_idx};

        for comp_idx=1:length(cluster_subj_temp)
            feat_idx=find(data_descripter(:,1)==cluster_subj_temp(comp_idx) & data_descripter(:,2)==cluster_comps_temp(comp_idx));
            cluster_descripter(feat_idx,1)=cluster_idx-2; 
        end
    end


    %% 3) select cluster
    acc_path=[data_path, 'accuracy', '.csv'];
    acc_arr=load(acc_path);
    acc_arr = repelem(acc_arr,num_branches);
    attr_arr=load([data_path, '\relative_contribution.mat']);
    attr_arr=attr_arr.attr_arr;
    TR=acc_arr.*attr_arr;

    % t-test
    p_arr=zeros(clust_num,1);

    for sort_cnt=1:clust_num
        test_idx=cluster_descripter==sort_cnt;
        test_rest_idx=find(cluster_descripter>0 & cluster_descripter~=sort_cnt);
        [~,p_arr(sort_cnt)] = ttest2(TR(test_idx),TR(test_rest_idx),...
            'Vartype','unequal','Tail','Right');
    end

    %% Visualization
    % task relevancy
    if draw_figures(1)==1

        figure;
        except_outlier=cluster_descripter>0;
        b = boxplot(TR(except_outlier), cluster_descripter(except_outlier), ...
        'Colors','k','Symbol','');
        ax=gca;
        ax.FontSize = 11;
        xlabel('Number of clusters','FontSize',12);
        ylabel('Task relevancy (%)','FontSize',12);
        ylim([-2 35])
        box off;

        t.TileSpacing = 'compact';
        t.Padding = 'compact';
    end

    % dipole distribution
    if draw_figures(2)==1
        STUDY = std_dipplot(STUDY,ALLEEG,'clusters',[3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18], 'design', 1);
    end
end