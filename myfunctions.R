###################################################
#Cost function for multiple linear regression
Cost_fct<-function(X, y, theta){
  # X: independant variables [X1 X2 ... Xn]
  # y: dependant variable
  # theta: parameters
  #####
  return( t(X%*%theta-y)%*%(X%*%theta-y)/(2*nrow(X)))
  
  
}

################################################################
# Gradient Descent function
Grad_Desc_fct<-function(X, y, theta, alpha, max_iter,tol=1e-7){
  #X: independant variables [X1 X2 ... Xn]
  #y: dependant variable
  #theta: parameters
  #alpha: learning rate
  #max_iter: maximum number of iterations
  #tol: Convergence tolerance, when the change resulting from an iteration is smaller than tol, the iterations are terminated (=1e-7 by default)
  ####
  # initialisation of vector of cost by iteration
  Cost_by_iter<- NULL# will be a vector of length nb_iter (nb_iter=number of iterations)
  #Normalizing X/ features scale (centered,scaled)
  Xmusig<-scale(X,center=TRUE,scale = TRUE)
  X_norm=labelled::remove_attributes(Xmusig,c("scaled:center","scaled:scale"))
  #mu and sigma
  mu=rbind(attr(Xmusig,which = "scaled:center"))
  sigma=rbind(attr(Xmusig,which = "scaled:scale"))
  # Adding  a column of ones to X normalized
  X_norm= cbind(1, X_norm,deparse.level = 0) 
  colnames(X)<-NULL
  ###
  nb_iter=0
    while ( (nb_iter<max_iter) & dist(rbind(0,c((alpha/nrow(X_norm))*t(X_norm)%*%(X_norm%*%theta-y))))>tol) {
      theta<-theta -(alpha/nrow(X_norm))*t(X_norm)%*%(X_norm%*%theta-y)
      Cost_by_iter <- rbind(Cost_by_iter,Cost_fct(X_norm, y, theta))
      nb_iter<-nb_iter+1
    }
    
    if(nb_iter==max_iter & dist(rbind(0,c((alpha/nrow(X_norm))*t(X_norm)%*%(X_norm%*%theta-y))))>tol){
      stop(paste("No convergence after ",max_iter," iterations!",sep = ""))
    }else{
      theta[1]<-theta[1]-sum(theta[-1]*mu/sigma)
      theta[-1]<-theta[-1]/sigma
      print(paste("alpha=",alpha,": Convergence realized after",nb_iter," iterations."))
      return(list(Cost_by_iter=Cost_by_iter,theta=cbind(theta),nb_iter=nb_iter))
    }
    
}
##############################################################################

#Function to create animated regression plane, as a function of the angle between x and y axis.
anime_plot<-function(sub.dir_name="RegPlots",min_angle=1,max_angle=180,rmv_sub.dir_after=TRUE){
  ########################################
  #sub.dir_name: name of the sub directory of the current directory, that will be created and will contain the png files ("RegPlots" by default)
  
  #min_angle: minimum angle between x and y axis (1 degree by default)
  
  #max_angle: maximum angle between x and y axis (180 degrees by default)
  
  #rmv_sub.dir_after: logical value indicating whether the sub directory containing the png plots will be deleted after the animate file is created (TRUE by default)
  
  ########################################
  
  #Creating a new sub directory
  dir.create(paste("./",sub.dir_name,sep = ""))
  ###

  index_plot=0
  #plot will be created for each angle (between x and y axis ) from min_angle to max_angle
  for(i in min_angle:max_angle){
    if(str_length(i)==1){
      index_plot=paste("00",i,sep = "")
    }else if(str_length(i)==2){
      index_plot=paste("0",i,sep = "")
    }else{
      index_plot=paste(i)
    }
    
    #will save the plot as a .png file in the sub directory sub.dir_name
    png(paste("./",sub.dir_name,"/plot",index_plot,".png",sep = ""),width = 700, height =500 )
    #creating the plot
    pl3D<-scatterplot3d(x=mtcars$disp, y=mtcars$wt,z=mtcars$mpg, pch = 19, type = "h", color = "red",
                        main = bquote("Animated Regression Plane: angle="~.(i)^o),xlab = "Displacement (cu.in.)",ylab = "Weight (1000 lbs)",zlab = "Miles/(US) gallon",
                        grid = T, box = F, 
                        mar = c(2.5, 2.5, 2, 1.5), 
                        angle =i)
    
    pl3D$plane3d(Intercept = theta[1],x.coef = theta[2],y.coef = theta[3],draw_polygon = TRUE,draw_lines = TRUE,polygon_args = list(col=rgb(.1,.2,.7,.5)))
    
    dev.off()
  }#end of for...
  
  list.files(path = "./RegPlots/", pattern = "*.png", full.names = TRUE) %>% #list file names
    (function(.) lapply(.,image_read)) %>% # reads each path file
    image_join() %>% # joins image
    image_animate(fps=4,) %>% # animates at fps frames per second
    image_write("myReg3Dplots.gif",quality = 100) # save to current directory
  
  
  #removing the directory if rmv_sub.dir_after=TRUE
  if(rmv_sub.dir_after) unlink("./RegPlots", recursive=TRUE)
  
}

#####################################################################################3

##Function to create static plot for a given angle (between x and y axis)
static_plot<-function(angle){
  pl3D<-scatterplot3d(x=mtcars$disp, y=mtcars$wt,z=mtcars$mpg, pch = 19, type = "h", color = "red",
                      main = bquote("Static Regression Plane: angle="~.(angle)^o),xlab = "Displacement (cu.in.)",ylab = "Weight (1000 lbs)",zlab = "Miles/(US) gallon",
                      grid = T, box = F, 
                      mar = c(2.5, 2.5, 2, 1.5), 
                      angle =angle )
  
  pl3D$plane3d(Intercept = theta[1],x.coef = theta[2],y.coef = theta[3],draw_polygon = TRUE,draw_lines = TRUE,polygon_args = list(col=rgb(.1,.2,.7,.5)))
}

