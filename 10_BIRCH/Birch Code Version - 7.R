

DataframeProcessing = function(x,thresholdvalue,pagesize)
{
  x = as.data.frame(x)
  for(i in c(1:nrow(x)))
  {
    MakeaCFTree(as.numeric(x[i,]),pagesize,thresholdvalue,i)
  }
}

BirchCF = function(x,Type = 'df',branchingfactor = 4, threshold = 0.15)
{
  mainlist <<-list();
  pagesize <<-branchingfactor
  if(is.data.frame(x))
  {
    
    DataframeProcessing(x,threshold,branchingfactor)
    y = mainlist[[1]];
    rm(mainlist,envir =.GlobalEnv)
    rm(pagesize,envir =.GlobalEnv)
    return(y)
  }
}
########################################Function to get the cf tree #################################################################


MakeaCFTree = function (x,pagesize,threshold,i)
{
  rowvector = as.numeric(x)#converting the data point into a numeric vector
  if(length(mainlist) == 0 )
  {
    #No CF's in the list. it will insert the CF into the node
    n = 1
    rootnode =0
    childnode = 0
    mainlist[[length(mainlist) + 1]] <<- vector('list',1)
    mainlist[[length(mainlist)]][[1]] <<- list(N = n,LS = rowvector,SS = rowvector*rowvector,RN =  rootnode,CN =  childnode,CNT =0,CI =array(i) )
    return(1);
  }
  else
  {
    #If there is already a node in the level 1
    parentnode = 0 #By default parNANAent node is 0 :)(self made :P)calculatenearestnode
    #Write code to calculate ls/n
    # print(calculatenearestnode(parentnode,rowvector,1))
    returnlist = calculatenearestnode(parentnode,rowvector,length(mainlist))
    depth = returnlist$depth
    index = returnlist$index
    count = returnlist$count
    Rootnode = returnlist$parentnode
    tempnode = mainlist[[depth]][[index]]
    linearsum = rowvector + tempnode$LS;
    squaredsum = (rowvector*rowvector)+ tempnode$SS;
    n = tempnode$N + 1
    radius = Compute_radius(linearsum,squaredsum,n)#calculate radius
    if(radius>threshold)
    {
      #print('radius is greater than threshold')
      if(count == pagesize)
      {
        splitNode(depth,index)#functiob returns depth and index, based on that insert off.:)
        temporarycf = mainlist[[depth]][[index]]
        mainlist[[depth]][[length(mainlist[[depth]])+1]]<<- list(N = 1, LS = rowvector, SS = (rowvector*rowvector), CN = temporarycf$CN,CNT = 0, RN = temporarycf$RN,CI = array(i) )
        #print("calling recalculate")
        recalculateCF(depth,index)
      }
      else
      {
        #print('entered2')
        n = 1
        childnode = 0
        len = length(mainlist[[depth]])+1
        mainlist[[depth]][[len]] <<-vector('list',1)
        
        mainlist[[depth]][[len]] <<- list(N = 1, LS = rowvector, SS = rowvector*rowvector, CN = 0,CNT = 0, RN = Rootnode,CI = array(i))
        recalculateCF(depth,len)
      }
      #Condition: 1, check if the branching factor allows you to insert 
      #condition: 2, check if you have to make it into two branches 
    }
    else
    {
      # print('radius is less than threshold')
      #merge the cf with the data point
      f = mainlist[[depth]][[index]]
      templist = list(N =(f$N)+1, LS = f$LS + rowvector, SS = f$SS + (rowvector*rowvector),CN = f$CN,CNT = f$CNT, RN = f$RN,CI = append(f$CI,i));
      mainlist[[depth]][[index]] <<- templist; 
      recalculateCF(depth,index)
    }
    
    
    
  }
}

Compute_radius = function (LS,SS,N)
{
  Y = SS - ((LS*LS)/N)
  return(sqrt(sum(Y)/N))
}

calculatenearestnode = function (parentnode,rowvector,depth)
{
  min = 0
  index = 0;
  count = 0;
  x = mainlist[[depth]]
  for(i in c(1:length(x)))
  {
    if(length(x[[i]]) != 0)
    {
      if( x[[i]]$RN == parentnode)
      {
        
        Centroid = (x[[i]]$LS)/(x[[i]]$N)
        tempsum = sum((rowvector - Centroid)*(rowvector - Centroid))
        if(count == 0)
        {
          min = tempsum;
          index = i;
        }
        if(min>tempsum)
        {
          index = i
          min = tempsum;
        }
        rm(tempsum);
        rm(Centroid);
        count = count+ 1;
      }
    }
  }
  if(x[[index]]$CNT !=0)
  {
    #reccursive function to travel deep into the tree
    return(calculatenearestnode(index,rowvector,(depth-1)))  
  }
  else
  {
    return(list(depth = depth,index = index,count = count,parentnode = parentnode))
  }
  
}

splitNode = function(depth,index)
{
  if(depth!= length(mainlist)){
    y = mainlist[[depth]][[index]]$RN
    mainlist[[depth+1]][[y]]$CN <<-index
    index = y
    depth = depth+1;
    
    
    actualnode = mainlist[[depth]][[index]]
    
    y = list();
    count = 0;
    x = mainlist[[depth]]
    for(i in c(1:length(x)))
    {
      
      if( x[[i]]$RN == actualnode$RN)
      {
        count = count + 1
      }
    }
    if(count == pagesize)
    {
      returnlist = splitNode(depth,index)
      depth = returnlist$depth
      index = returnlist$index
      if(mainlist[[depth]][[index]]$CN != 0)
        return(rearrange(depth,index))
      else
        return(list(depth = depth,index = index))
    }
    else
    {
      
      
      return(rearrange(depth,index)) 
      #write the code to return back 
      
    }
  }
  else
  {
    actualnode = mainlist[[depth]][[index]]
    
    y = list();
    count = 0;
    x = mainlist[[depth]]
    for(i in c(1:length(x)))
    {
      
      if( x[[i]]$RN == actualnode$RN)
      {
        count = count + 1
      }
    }
    if(count == pagesize)
    {
      return(createnewnodetop(depth,index))
      #rearrange(depth,index)
    }
  }
}

rearrange = function(depth,index)
{
  Mainchild = mainlist[[depth]][[index]];
  y = list();
  distvec = array();
  indexvector= array();
  for( i in c(1:length(mainlist[[depth-1]])))
  {
    if(mainlist[[depth-1]][[i]]$RN == index)
    {
      g = mainlist[[depth-1]][[i]]$LS;
      distvec = append(distvec, sum((as.numeric(g) - as.numeric(rep(0,length(g))))^2))
      indexvector=append(indexvector,i)
    }
  }
  distvec = distvec[2:length(distvec)]
  indexvector = indexvector[2:length(indexvector)]
  arrayindexes = order(distvec);
  cf1list = arrayindexes[1:ceiling(length(arrayindexes)/2)]
  cf2list = arrayindexes[(ceiling(length(arrayindexes)/2)+1):(length(arrayindexes))]
  CF1index = list();
  CF2index = list();
  for(i in c(cf1list))
  {
    if(length(CF1index)==0)
    {
      CF1index = mainlist[[depth-1]][[indexvector[i]]]
      CF1index$CNT = 1
      mainlist[[depth-1]][[indexvector[i]]]$RN<<-index
    }
    else
    {
      z = mainlist[[depth-1]][[indexvector[i]]]
      CF1index = list(N =(CF1index$N)+z$N, LS = CF1index$LS + z$LS, SS = CF1index$SS + z$SS,CNT = Mainchild$CNT,CN = Mainchild$CN, RN = Mainchild$RN);
      mainlist[[depth-1]][[indexvector[i]]]$RN<<-index
    }
  }
  
  #########
  
  ########
  for(i in c(cf2list))
  {
    
    if(length(CF2index)==0)
    {
      CF2index = mainlist[[depth-1]][[indexvector[i]]]
      mainlist[[depth-1]][[indexvector[i]]]$RN<<- length(mainlist[[depth]])+1
    }
    else
    {
      z = mainlist[[depth-1]][[indexvector[i]]]
      CF2index = list(N =(CF2index$N)+z$N, LS = CF2index$LS + z$LS, SS = CF2index$SS + z$SS,CNT =Mainchild$CNT, CN = Mainchild$CN, RN = Mainchild$RN);
      mainlist[[depth-1]][[indexvector[i]]]$RN<<- length(mainlist[[depth]])+1
    }
  }
  CF1index$RN = Mainchild$RN
  mainlist[[depth]][[index]] <<- CF1index;
  CF2index$RN =Mainchild$RN 
  mainlist[[depth]][[length(mainlist[[depth]])+1]]<<- CF2index;
  rm(CF2index,CF1index)
  return(list(depth = depth-1,index = Mainchild$CN))
}

createnewnodetop = function(depth,index)
{
  depth = length(mainlist);
  distvec = array();
  indexvector= array();
  for( i in c(1:length(mainlist[[depth]])))
  {
    if(mainlist[[depth]][[i]]$RN == 0)
    {
      g = mainlist[[depth]][[i]]$LS;
      distvec =append(distvec, sum((as.numeric(g) - as.numeric(rep(0,length(g))))^2))
      indexvector= append(indexvector,i)
    }
  }
  distvec = distvec[2:length(distvec)]
  indexvector = indexvector[2:length(indexvector)]
  arrayindexes = order(distvec);
  cf1list = arrayindexes[1:ceiling(length(arrayindexes)/2)]
  cf2list = arrayindexes[(ceiling(length(arrayindexes)/2)+1):(length(arrayindexes))]
  CF1index = list();
  CF2index = list();
  for(i in c(cf1list))
  {
    if(length(CF1index)==0)
    {
      CF1index = mainlist[[depth]][[indexvector[i]]]
      CF1index$CNT = 1
      mainlist[[depth]][[indexvector[i]]]$RN <<-1
    }
    else
    {
      z = mainlist[[depth]][[indexvector[i]]]
      CF1index = list(N =(CF1index$N)+z$N, LS = CF1index$LS + z$LS, SS = CF1index$SS + z$SS,CNT = 1+CF1index$CNT,CN = 0, RN = 0);
      mainlist[[depth]][[indexvector[i]]]$RN<<- 1
    }
  }
  for(i in c(cf2list))
  {
    if(length(CF2index)==0)
    {
      CF2index = mainlist[[depth]][[indexvector[i]]]
      CF2index$CNT = 1
      mainlist[[depth]][[indexvector[i]]]$RN<<-2
    }
    else
    {
      z = mainlist[[depth]][[indexvector[i]]]
      CF2index = list(N =(CF2index$N)+z$N, LS = CF2index$LS + z$LS, SS = CF2index$SS + z$SS,CNT = 1+CF1index$CNT,CN = 0 , RN = 0 );
      mainlist[[depth]][[indexvector[i]]]$RN<<- 2
    }
  }
  mainlist[[length(mainlist)+1]] <<-vector('list',2);
  mainlist[[depth+1]][[1]] <<- CF1index;
  mainlist[[depth+1]][[2]]<<- CF2index;
  return(list(depth = depth,index = index))
}

recalculateCF = function(depth,index)
{
  # print('entered recalculate') 
  CFindex = list()
  for(i in c(1:length(mainlist[[depth]])))
  {
    if(mainlist[[depth]][[i]]$RN == mainlist[[depth]][[index]]$RN)
    {
      if(length(CFindex)==0)
      {
        CFindex = mainlist[[depth]][[i]]
        CFindex$CNT = 1
      }
      else
      {
        z = mainlist[[depth]][[i]]
        CFindex = list(N =(CFindex$N)+z$N, LS = CFindex$LS + z$LS, SS = CFindex$SS + z$SS,CNT = 1+CFindex$CNT,CN = z$CN, RN = 0 );
        
      }
    }
    
  }
  x = mainlist[[depth]][[index]]$RN
  if(depth != length(mainlist)){
    CFindex$RN = mainlist[[depth+1]][[x]]$RN
    CFindex$CN = mainlist[[depth+1]][[x]]$CN
    mainlist[[depth+1]][[x]] <<-CFindex;
    
    if(mainlist[[depth+1]][[x]]$RN ==0)
    {
      return(1)
    }
    else{
      recalculateCF(depth+1,x)
    }
  }
  else
  {
    return(1)
  }
}


#########################################Clustering Algorithm###########################################################

Fit = function (Type, element, nClusters, nStart,iter.max = 100,method= "complete")
{
  array1 = array();
  array2 = array();
  centroid = matrix(nrow = length(element),ncol = length(element[[1]]$LS)) #matrix for clustering
  for(i in c(1:length(element)))
  {
    centroid[i,] = (c(element[[i]]$LS/element[[i]]$N))
  }
  if(Type =='kmeans'){
    kclust = kmeans(x = centroid,centers = nClusters,nstart = nStart,iter.max = 100)
    cluster = kclust$cluster
  }
  else if (Type == 'hclust'){
    print("H - Cluster")
    hcluster = hclust(dist(centroid), method)
    cluster = cutree(hcluster, nClusters)
  }
  for (i in c(1:length(element)))
  {
    elementarray = element[[i]]$CI
    for(j in c(1:length(elementarray)))
    {
      array1 = append(array1,elementarray[j])
      array2 = append(array2,cluster[i])
    }
  }
  array1 = array1[2:length(array1)]
  array2 = array2[2:length(array2)]
  x = cbind(array1,array2)
  return(x[order(x[,1]),])
}
