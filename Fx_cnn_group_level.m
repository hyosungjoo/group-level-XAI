% Fx_cnn_group_level() - group-level analysis based on compact CNN
%               only clustering and selection process are included

% Input: 
%   STUDY         - A current EEGLAB STUDY
%   ALLEEG        - a current EEGLAB ALLEEG
%   features      - Feature array except with dipole location (NXM 2-D array)
%                  => N denotes the number of convolutional filters (our case: 800)
%                  => M denotes the number of features except with dipole location (our case: 3)
%   weights       - Weights for clustering process (1-D array, our case had two weights - spectral features, dipole location)
%   draw_figures  - Flag for drawing figures (0: off, 1: on)
%                  => For example, using [1, 1] will enable us to visualize Figure 1 (task relevancy bar graph) and Figure 2 (dipole distribution)
%   data_path     - Path which includes data (The EEGlab dataset containing the dipole fitting results must be saved in the dipfit folder in data_path)

% Outputs:
%   STUDY         - A new STUDY set containing some or all of the datasets in ALLEEG, 
%   ALLEEG        - A vector of EEG datasets included in the STUDY structure 
%   group_output  - A structure to contain the selected number of clusters and convolutional filters belonging to selected clusters.
%                   => convolutional filters represented with the subject number and branches, including convolutional filters.

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


function [STUDY, ALLEEG, group_output]= Fx_cnn_group_level(STUDY, ALLEEG, features, weights, draw_figures, data_path)
    
    %% 1) make study
    % make a study
    eeg_path=[data_path, 'eeg_dipfit\'];
    list = cellstr(ls([eeg_path,'*.set']));
    EEG = pop_loadset('filename',list,'filepath',eeg_path);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'study',0);
    [STUDY ALLEEG] = std_checkset(STUDY, ALLEEG);
    [STUDY ALLEEG] = std_editset( STUDY, ALLEEG, 'name','group-level','commands',{{'index',1,'subject','1'},{'inbrain','on','dipselect',0.15},{'index',2,'subject','2'},{'index',3,'subject','3'},{'index',4,'subject','4'},{'index',5,'subject','5'},{'index',6,'subject','6'},{'index',7,'subject','7'},{'index',8,'subject','8'},{'index',9,'subject','9'},{'index',10,'subject','10'},{'index',11,'subject','11'},{'index',12,'subject','12'},{'index',13,'subject','13'},{'index',14,'subject','14'},{'index',15,'subject','15'},{'index',16,'subject','16'},{'index',17,'subject','17'},{'index',18,'subject','18'},{'index',19,'subject','19'},{'index',20,'subject','20'},{'index',21,'subject','21'},{'index',22,'subject','22'},{'index',23,'subject','23'},{'index',24,'subject','24'},{'index',25,'subject','25'},{'index',26,'subject','26'},{'index',27,'subject','27'},{'index',28,'subject','28'},{'index',29,'subject','29'},{'index',30,'subject','30'},{'index',31,'subject','31'},{'index',32,'subject','32'},{'index',33,'subject','33'},{'index',34,'subject','34'},{'index',35,'subject','35'},{'index',36,'subject','36'},{'index',37,'subject','37'},{'index',38,'subject','38'},{'index',39,'subject','39'},{'index',40,'subject','40'},{'index',41,'subject','41'},{'index',42,'subject','42'},{'index',43,'subject','43'},{'index',44,'subject','44'},{'index',45,'subject','45'},{'index',46,'subject','46'},{'index',47,'subject','47'},{'index',48,'subject','48'},{'index',49,'subject','49'},{'index',50,'subject','50'}},'updatedat','on','savedat','on','rmclust','on' );
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
    feat_arr=[features, dip_arr];
    feat_arr(~logical(rej_idx),:)=[];

    % normalize featuers
    norm_feat=(feat_arr-mean(feat_arr))./std(feat_arr);

    % precompute component measure
    if isempty(ls([eeg_path,'*.icaspec']))
        [STUDY, ALLEEG] = std_precomp(STUDY, ALLEEG, 'components','savetrials','on','recompute','on','spec','on','specparams',{'specmode','fft','logtrials','off'});
    end
    
    % set preclustering array
    [STUDY ALLEEG] = std_preclust(STUDY, ALLEEG, 1,{'spec','npca',size(features,2),'weight',1,'freqrange',[3 25] },{'dipoles','weight',1});
    
    
    norm_feat(:,1:size(features,2))=norm_feat(:,1:size(features,2))*weights(1);
    norm_feat(:,size(features,2)+1:end)=norm_feat(:,size(features,2)+1:end)*weights(2);

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

    for p_cnt=1:clust_num
        test_idx=cluster_descripter==p_cnt;
        test_rest_idx=find(cluster_descripter>0 & cluster_descripter~=p_cnt);
        [~,p_arr(p_cnt)] = ttest2(TR(test_idx),TR(test_rest_idx),...
            'Vartype','unequal','Tail','Right');
    end
    
    selec_clust_idx=find(p_arr<0.001);
    group_output.select_clust=selec_clust_idx;
    
    if isempty(selec_clust_idx)
       [~,selec_clust_idx]=min(p_arr); 
    end
    group_output.select_filter=cell(length(selec_clust_idx),1);
    for clust_cnt=1:length(selec_clust_idx)
        group_output.select_filter{clust_cnt}=data_descripter(cluster_descripter==selec_clust_idx(clust_cnt),:);
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