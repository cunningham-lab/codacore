
library(tensorflow)
library(keras)

deepcoda = function(
  x,
  y,
  selfExplanation = FALSE,
  epochs = 200,
  lambdaC = 1,
  lambdaS = 0.01,
  hiddenUnits = 16,
  logBotts = 5,
  batchSize = 32
) {
  
  # We use the defaults from the DeepCoDA paper
  
  # Convert x and y to the appropriate objects
  if (class(y) == 'data.frame') {y = as.numeric(y[[1]]) - 1}
  else if (class(y) == 'factor') {y = as.numeric(y) - 1}
  if (class(x) == 'data.frame') {x = as.matrix(x)}
  if (is.integer(x)) {x = x * 1.0}
  
  # If the data is un-normalized (e.g. raw counts),
  # we normalize it to ensure our learning rate is well calibrated
  x = x / rowSums(x)
  
  # Convert our data to tensors
  xTf = tf$convert_to_tensor(log(x), dtype='float32')
  yTf = tf$convert_to_tensor(y, dtype='float32')
  
  xTrain = k_constant(log(x))
  yTrain = k_constant(y)
  
  numObs = nrow(x)
  inputDim = ncol(x)
  
  if (selfExplanation) {
    keras_model_deepcoda <- function(num_classes, 
                                     name = NULL) {
      
      # define and return a custom model
      keras_model_custom(name = name, function(self) {
        
        # create layers we'll need for the call (this code executes once)
        self$beta0 = tf$Variable(tf$zeros(shape(1, logBotts)), trainable=T)
        self$beta = tf$Variable(initializer_glorot_uniform()(shape(inputDim, logBotts)), trainable=T)
        self$dense1 <- layer_dense(units=hiddenUnits, activation = "relu")
        self$dense2 <- layer_dense(units=logBotts, activation = "linear")
        
        # implement call (this code executes during training & inference)
        function(inputs, mask = NULL, training = FALSE) {
          # Add a constant beta0
          z = k_dot(inputs, self$beta) + self$beta0
          theta = self$dense2(self$dense1(z))
          k_sum(z * theta, axis=0)
        }
      })
    }
  } else {
    keras_model_deepcoda <- function(num_classes, 
                                     name = NULL) {
      
      # define and return a custom model
      keras_model_custom(name = name, function(self) {
        
        # create layers we'll need for the call (this code executes once)
        self$beta0 = tf$Variable(tf$zeros(shape(1, logBotts)), trainable=T)
        self$beta = tf$Variable(initializer_glorot_uniform()(shape(inputDim, logBotts)), trainable=T)
        self$dense <- layer_dense(units=1, activation = "linear")
        # self$dense2 <- layer_dense(units=logBotts, activation = "linear")
        
        # implement call (this code executes during training & inference)
        function(inputs, mask = NULL, training = FALSE) {
          # Add a constant beta0
          z = k_dot(inputs, self$beta) + self$beta0
          self$dense(z)
          # theta = self$dense2(self$dense1(z))
          # k_sum(z * theta, axis=0)
        }
      })
    }
  }

  
  model = keras_model_deepcoda()
  optimizer = optimizer_adam()
  library(tfdatasets)
  train_dataset <- tensor_slices_dataset(list (xTrain, yTrain)) %>% 
    dataset_batch(10)
  for (epoch in 1:epochs) {
    print(epoch)
    iter <- make_iterator_one_shot(train_dataset)
    
    # loop once through the dataset
    until_out_of_range({
      
      # get next batch
      batch <-  iterator_get_next(iter)
      xBatch <- batch[[1]]
      yBatch <- batch[[2]]
      
        
      with(tf$GradientTape() %as% tape, {
        # Forward pass
        yHat <- k_sigmoid(model(xBatch))
        
        reg1 = lambdaC * k_sum(k_square(k_sum(model$beta, axis=1)))
        reg2 = lambdaS * k_sum(k_abs(model$beta))
        xe = loss_binary_crossentropy(yBatch, yHat)
        # compute the loss
        loss <- xe + reg1 + reg2
      })
      
      # get gradients of loss w.r.t. model weights
      gradients <- tape$gradient(loss, model$variables)
      # update model weights
      optimizer$apply_gradients(
        purrr::transpose(list(gradients, model$variables))
        # global_step = tf$train$get_or_create_global_step()
      )
      
    })
  }
  
  out = list(x=x, y=y, model=model)
  class(out) = 'deepcoda'
  out
}


predict.deepcoda = function(dcd, x, logits=T) {
  if (class(x) == 'data.frame') {x = as.matrix(x)}
  if (is.integer(x)) {x = x * 1.0}
  x = x / rowSums(x)
  
  # Convert our data to tensors
  xTf = tf$convert_to_tensor(log(x), dtype='float32')
  
  yHat = dcd$model$call(xTf)
  yHat = as.numeric(yHat)

  if (logits) {
    return(yHat)
  } else {
    return(1 / (1 + exp(-yHat)))
  }
}

numActiveVars.deepcoda = function(dcd) {
  beta = as.matrix(dcd$model$beta)
  nonZeroEntries = abs(beta) > 0.005
  activeVars = apply(nonZeroEntries, 1, any)
  sum(activeVars)
}


