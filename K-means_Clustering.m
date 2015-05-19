%--------------------------------------------------------------------------
%                                                                         |
%Title: Implementing K-means clustering                                   |
%Programmer: Mohammad Mohammadi (also known as M2)                        |
%Codename: This Is How We Do                                              |
%Date: 2013/12/23                                                         |
%Details: This is homework assignment for DSS course Shiraz University    |
%    first semester 2013-2014. The details was handed in a requirement    |
%    specification document handed to students.                           |
%--------------------------------------------------------------------------

function clustering2

    %Clears everything!
    clear all;

    % Shows a graphical dialog for browsing. It only allows .data files. As
    % it was mandated by project guide. Returns file name and path of
    % chosen file in respective variables.
    [fileName,path]=uigetfile('*.data');

    %Here we load the specified file into rawData.
    dataSet=load([path,fileName]);

    %As instructed in the project guide we eliminate data from first and
    %second column. This data is redundant for our process.
    dataSet(:,1:2)=[];

    %We determine the maximum and minimum values of each column so when we
    %want to generate cluster centers for first time, we would have
    %reasonable range of numbers to generate randoms between them.
    minValues=min(dataSet,[],1);
    minValues(:,3)=[];
    maxValues=max(dataSet,[],1);
    maxValues(:,3)=[];

    %Randomly selecting cluster centers for the first time.
    clusteringCenters=intializeClusterCenter(minValues,maxValues);

    %A boolean variable set to ture. This variable tells while to conitune
    %looping until set to false (when we found cluster centers).
    keepLooping = true;

    %Start of loop. The loop iretates until the cluster centers don't
    %change.
    while keepLooping

        %Calculates the distance of each points with each cluster centers
        %and assign each of points to nearest cluster center.
        distanceWithCenters=pdist2(dataSet(:,1:2),clusteringCenters,'euclidean');
        [~,clusterIndices] = min(distanceWithCenters,[],2);

        %Adds cluster number of each point to its respective row and column
        %4 of dataset.
        dataSet(:,4)=clusterIndices;

        %Here we calculate new cluster centers by calculating mean values
        %of points in each cluster.
        [newClusteringCenters] = grpstats(dataSet(:,1:2),dataSet(:,4),{'mean'});

        %Showing points with different colors representing their clusters.
        %Using 'hold on' to add cluster centers,
        gscatter(dataSet(:,1),dataSet(:,2),dataSet(:,4),'brg','...',[15,15,15],'off','First Column Values','Second Column Values');
        hold on;

        %Adding cluster centers to plot.
        scatter(clusteringCenters(:,1),clusteringCenters(:,2),200,'*','k');
        hold off;

        %Sometimes because of randomly selecting approach, points would go
        %to less number of clusters than desired. We calculate number of
        %new cluster of centers. If this number is not eqaul to 3 (then its
        %less than 3) then there is at least one cluster with empty set.
        %This leads to eror. So we initialize cluster centers again. Then
        %showing a message box to aware the user
        [numberOfNewClusteringCenters,~]=size(newClusteringCenters);
        if numberOfNewClusteringCenters ~= 3
            clusteringCenters=intializeClusterCenter(minValues,maxValues);
            msgbox('Random cluster centers made number of cluster less than 3 so cluster center has been reinitialized','Warning');
            continue;
        end

        %Slowing down the process so it would be visible how the clusters
        %change.
        pause(2);

        %Checks if we should continue the fitting the clusters. If the
        %cluster centers don't change the algorithm has ended.
        if clusteringCenters == newClusteringCenters
            keepLooping = false;
        else
            clusteringCenters = newClusteringCenters;
        end
    end

    %Demonstarating last changes in the plot since we plot at begining of
    %loop (we could do it differently but it is more neat this way).
    gscatter(dataSet(:,1),dataSet(:,2),dataSet(:,4),'brg','...',[15,15,15],'off','First Column Values','Second Column Values');
    hold on;
    scatter(clusteringCenters(:,1),clusteringCenters(:,2),200,'*','k');
    hold off;

    %We determine differently clustered points with subtracting cluster
    %values assigned by input file from cluster values assigned by this
    %program. If the subtraction equals to zero then we assigned that point
    %to the same cluster as input file did so this is a currectly clustered
    %point.
    dataSet(:,5)= dataSet(:,3)-dataSet(:,4);
    correctClusteredPercentage = mean(dataSet(:,5) == 0) * 100;

    %A dialog box that shows percentage of correctly clustered points.
    msgbox(['The correctly clustered percentage is: ',num2str(correctClusteredPercentage),'%'],'Report');
end

function [clusteringCenters] = intializeClusterCenter(minValues,maxValues)
    %Here we allocate random values to cluster centers. Values are between
    %maximum and minimum values of points. This way we rationalize our
    %cluster centers into reasonable bounds
    clusteringCenters(1:3,1) = minValues(1,1) + (maxValues(1,1)-minValues(1,1)).*rand(3,1);
    clusteringCenters(1:3,2) = minValues(1,2) + (maxValues(1,2)-minValues(1,2)).*rand(3,1);

    %This section sorts randomly selected cluster centers.The sort is based
    %on euclidean distance between cluster centers and origin point. This
    %way points' clusters would have names in way that if they are closer
    %to the origin the cluster number is lower. This is the way that input
    %file named its clusters. Naming our clusters in the same way helps
    %detect difference between our clusters and input clusters.
    clusteringCenters(1:3,3)=pdist2([0 0],clusteringCenters,'euclidean');
    clusteringCenters = sortrows(clusteringCenters,3);
    clusteringCenters(:,3)=[];
end