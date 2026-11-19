#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#%% Blackjack Markov Chain Toolbox, v1.0 (08 Jan 2009)
#%% 
#%% Companion to manuscript 
#%%    "A Markov Chain Analysis of Blackjack Strategy"
#%%    by Michael B. Wakin and Christopher J. Rozell, 2004.
#%%    available at: http://inside.mines.edu/~mwakin/papers/mcbj.pdf
#%%
#%% Software Copyright 2009 by 
#%%    Michael B. Wakin, Colorado School of Mines, mwakin@mines.edu
#%%    Christopher J. Rozell, Georgia Tech, crozell@gatech.edu 
#%%
#%% This software is released under a Creative Commons license
#%% (Attribution 3.0 Unported): 
#%%     http://creativecommons.org/licenses/by/3.0/
#%% You are free:
#%%    * to Share — to copy, distribute and transmit the work
#%%    * to Remix — to adapt the work
#%% Under the following conditions:
#%%   * You must attribute the work by retaining this header information
#%%     crediting the original authors and linking to the original
#%%     manuscript.
#%%   * For any reuse or distribution, you must make clear to others the 
#%%     license terms of this work.
#%%   * Any of the above conditions can be waived if you get permission 
#%%     from the copyright holder.
#%%   * Nothing in this license impairs or restricts the author's 
#%%     moral rights.
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# 
# 
# R/Shiny adaptation (2026): interactive educational play-money simulator.
# Original manuscript: https://repository.rice.edu/items/1abebb50-9696-465c-8ed5-7c4a6f33c890
# Original license: https://creativecommons.org/licenses/by/3.0/
# Adaptation retains source tables and changes matrix powers to recursive absorption.
# Run: install.packages("shiny"); source("Blackjack_MC_Shiny.R")

options(shiny.maxRequestSize = 5 * 1024^2)

# ----- Original strategy tables from setupVariables.m -----
basic.pairStrategyDASA <- matrix(c(
  4, 4, 4, 4, 4, 4, 3, 3, 3, 3,
  4, 4, 4, 4, 4, 4, 3, 3, 3, 3,
  3, 3, 3, 4, 4, 3, 3, 3, 3, 3,
  1, 1, 1, 1, 1, 1, 1, 1, 3, 3,
  4, 4, 4, 4, 4, 3, 3, 3, 3, 3,
  4, 4, 4, 4, 4, 4, 3, 3, 3, 3,
  4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
  4, 4, 4, 4, 4, 0, 4, 4, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  4, 4, 4, 4, 4, 4, 4, 4, 4, 4
), ncol = 10, byrow = TRUE)

basic.softStrategy <- matrix(c(
  3, 3, 3, 3, 1, 3, 3, 3, 3, 3,
  3, 3, 3, 3, 1, 3, 3, 3, 3, 3,
  3, 3, 3, 1, 1, 3, 3, 3, 3, 3,
  3, 3, 1, 1, 1, 3, 3, 3, 3, 3,
  3, 3, 1, 1, 1, 3, 3, 3, 3, 3,
  3, 1, 1, 1, 1, 3, 3, 3, 3, 3,
  0, 2, 2, 2, 2, 0, 0, 3, 3, 3,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0
), ncol = 10, byrow = TRUE)

basic.hardStrategy <- matrix(c(
  3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
  3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
  3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
  3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
  3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
  3, 1, 1, 1, 1, 3, 3, 3, 3, 3,
  1, 1, 1, 1, 1, 1, 1, 1, 3, 3,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 3,
  3, 3, 0, 0, 0, 3, 3, 3, 3, 3,
  0, 0, 0, 0, 0, 3, 3, 3, 3, 3,
  0, 0, 0, 0, 0, 3, 3, 3, 3, 3,
  0, 0, 0, 0, 0, 3, 3, 3, 5, 3,
  0, 0, 0, 0, 0, 3, 3, 5, 5, 5,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0
), ncol = 10, byrow = TRUE)

thorp.hardDrawStand <- matrix(c(
  Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf,
  Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf,
  Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf,
  Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf,
  Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf,
  Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf,
  Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf,
  Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf,
  14, 6, 2, -1, 0, Inf, Inf, Inf, Inf, Inf,
  1, -2, -5, -9, -8, 50, Inf, Inf, Inf, Inf,
  -5, -8, -13, -17, -17, 20, 38, Inf, Inf, Inf,
  -12, -17, -21, -26, -28, 13, 15, 12, 8, 16,
  -21, -25, -30, -34, -35, 10, 11, 6, 0, 14,
  -Inf, -Inf, -Inf, -Inf, -Inf, -Inf, -Inf, -Inf, -Inf, -15,
  -Inf, -Inf, -Inf, -Inf, -Inf, -Inf, -Inf, -Inf, -Inf, -Inf,
  -Inf, -Inf, -Inf, -Inf, -Inf, -Inf, -Inf, -Inf, -Inf, -Inf,
  -Inf, -Inf, -Inf, -Inf, -Inf, -Inf, -Inf, -Inf, -Inf, -Inf,
  -Inf, -Inf, -Inf, -Inf, -Inf, -Inf, -Inf, -Inf, -Inf, -Inf
), ncol = 10, byrow = TRUE)

thorp.softDrawStand <- matrix(c(
  Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf,
  Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf,
  Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf,
  Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf,
  Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf,
  Inf, Inf, Inf, Inf, Inf, 29, Inf, Inf, Inf, Inf,
  -Inf, -Inf, -Inf, -Inf, -Inf, -Inf, -Inf, Inf, 12, -6,
  -Inf, -Inf, -Inf, -Inf, -Inf, -Inf, -Inf, -Inf, -Inf, -Inf,
  -Inf, -Inf, -Inf, -Inf, -Inf, -Inf, -Inf, -Inf, -Inf, -Inf,
  -Inf, -Inf, -Inf, -Inf, -Inf, -Inf, -Inf, -Inf, -Inf, -Inf
), ncol = 10, byrow = TRUE)

thorp.hardDouble <- matrix(c(
  Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf,
  Inf, Inf, Inf, 20, 26, Inf, Inf, Inf, Inf, Inf,
  Inf, Inf, 27, 18, 24, Inf, Inf, Inf, Inf, Inf,
  Inf, 45, 21, 14, 17, Inf, Inf, Inf, Inf, Inf,
  Inf, 22, 11, 5, 5, 22, Inf, Inf, Inf, Inf,
  3, 0, -5, -10, -12, 4, 14, Inf, Inf, Inf,
  -15, -17, -21, -24, -26, -17, -9, -3, 7, 6,
  -23, -26, -29, -33, -35, -26, -16, -10, -9, -3,
  Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf,
  Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf,
  Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf,
  Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf,
  Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf,
  Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf,
  Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf,
  Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf,
  Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf,
  Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf
), ncol = 10, byrow = TRUE)

thorp.softDouble <- matrix(c(
  Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf,
  Inf, 10, 2, -19, -13, Inf, Inf, Inf, Inf, Inf,
  Inf, 11, -3, -13, -19, Inf, Inf, Inf, Inf, Inf,
  Inf, 19, -7, -16, -23, Inf, Inf, Inf, Inf, Inf,
  Inf, 21, -6, -16, -32, Inf, Inf, Inf, Inf, Inf,
  Inf, -6, -14, -28, -30, Inf, Inf, Inf, Inf, Inf,
  Inf, -2, -15, -18, -23, Inf, Inf, Inf, Inf, Inf,
  Inf, 9, 5, 1, 0, Inf, Inf, Inf, Inf, Inf,
  Inf, 20, 12, 8, 8, Inf, Inf, Inf, Inf, Inf,
  Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf
), ncol = 10, byrow = TRUE)

thorp.pairSplit <- matrix(c(
  -9, -15, -22, -30, -Inf, -Inf, Inf, Inf, Inf, Inf,
  -21, -34, -Inf, -Inf, -Inf, -Inf, Inf, Inf, Inf, Inf,
  Inf, 18, 8, 0, Inf, Inf, Inf, Inf, Inf, Inf,
  Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf,
  0, -3, -8, -13, -16, -8, Inf, Inf, Inf, Inf,
  -22, -29, -35, -Inf, -Inf, -Inf, -Inf, Inf, Inf, Inf,
  -Inf, -Inf, -Inf, -Inf, -Inf, -Inf, -Inf, -Inf, Inf, -18,
  -3, -8, -10, -15, -14, 8, -16, -22, Inf, 10,
  25, 17, 10, 6, 7, 19, Inf, Inf, Inf, Inf,
  -Inf, -Inf, -Inf, -Inf, -Inf, -33, -24, -22, -20, -17
), ncol = 10, byrow = TRUE)

# ----- Model 2: shoe chain (reshuffle.m, equilib.m, lmh2deckPdf.m) -----
# For n dealt cards, mu[n] is the normalized survival probability of the
# cut point. Conditional on n, (L,M,H) is multivariate hypergeometric.
# This is exactly the original columnwise balance recursion, in closed form.
shoe_equilibrium <- function(decks) {
  N <- 52L * decks
  n <- 0:N
  mass <- ifelse(n >= floor(N/2), exp(-abs(n - .75*N)/sqrt(N/20)), 0)
  mass <- mass/sum(mass)
  survival <- rev(cumsum(rev(mass)))
  hazard <- mass/survival
  mu <- survival/sum(survival)
  stopifnot(abs(sum(mu)-1) < 1e-10,
            max(abs(mu[-1] - mu[-length(mu)]*(1-hazard[-length(hazard)]))) < 1e-10,
            abs(mu[1] - sum(mu*hazard)) < 1e-10)
  list(N=N, decks=decks, cut=mass, hazard=hazard, mu=mu)
}
# Toolbox category counts are numbers played, not numbers remaining.
shoe_state <- function(eq, lmh) {
  n <- sum(lmh); R <- eq$N-n
  stopifnot(length(lmh)==3L, all(lmh>=0), all(lmh<=c(20,12,20)*eq$decks), R>0)
  remaining <- c(20,12,20)*eq$decks-lmh
  pdf <- c(remaining[3]/5, rep(remaining[1]/5,5),
           rep(remaining[2]/3,3), 4*remaining[3]/5)/R
  pi <- eq$mu[n+1]*exp(sum(lchoose(c(20,12,20)*eq$decks,lmh))-lchoose(eq$N,n))
  list(lmh=lmh, n=n, R=R, hli=100*(lmh[1]-lmh[3])/R, pdf=pdf,
       pi=pi, depth_mu=eq$mu[n+1], hazard=eq$hazard[n+1])
}
# Exact long-run HLI histogram, no dense million-by-million matrix.
# Each column is vectorized. Last (empty shoe) state has undefined HLI.
hli_equilibrium <- function(eq) {
  L <- 20L*eq$decks; M <- 12L*eq$decks; H <- L
  bins <- -100:100; hist <- numeric(length(bins))
  for(n in 0:(eq$N-1L)) {
    lo <- max(0L,n-M-H):min(L,n)
    med <- 0:min(M,n)
    x <- rep(lo,each=length(med)); y <- rep(med,times=length(lo)); z <- n-x-y
    ok <- z>=0 & z<=H; x <- x[ok]; y <- y[ok]; z <- z[ok]
    w <- eq$mu[n+1]*exp(lchoose(L,x)+lchoose(M,y)+lchoose(H,z)-lchoose(eq$N,n))
    h <- as.integer(round(100*(x-z)/(eq$N-n)))+101L
    a <- rowsum(matrix(w,ncol=1),h,reorder=FALSE); hist[as.integer(rownames(a))] <- hist[as.integer(rownames(a))]+a[,1]
  }
  stopifnot(abs(sum(hist)-sum(eq$mu[-length(eq$mu)]))<1e-8)
  data.frame(hli=bins, probability=hist/sum(hist))
}
# ----- Strategy tables (setStrategy.m) -----
# Source table values: 0 stand, 1 double/else hit, 2 double/else stand,
# 3 hit, 4 split, 5 surrender/else hit. Dealer columns 2..10,A.
make_policy <- function(hli=0, basic=FALSE) {
  if(basic) return(list(hard=basic.hardStrategy,soft=basic.softStrategy,pair=basic.pairStrategyDASA))
  convert <- function(d,s) ifelse(hli>d,1L,ifelse(hli>s,0L,3L))
  hard <- convert(thorp.hardDouble,thorp.hardDrawStand)
  soft <- convert(thorp.softDouble,thorp.softDrawStand)
  if(hli>=1 && hli<=10) soft[6,1] <- 1L
  pair <- rbind(hard[2*(2:10)-3,,drop=FALSE],soft[1,,drop=FALSE])
  pair[hli>thorp.pairSplit] <- 4L
  # Correct intended pair row indices from source special cases (8-8, 3-3).
  # Source setStrategy.m writes 2*pNum-1, which is not the pair row index.
  if(hli<24) pair[7,9] <- 4L
  if(hli>6 || hli< -2) pair[2,7] <- 4L
  list(hard=hard,soft=soft,pair=pair)
}
# ----- Model 1: absorbing hand chains (calcDealerTrans.m, calcPlayerTrans.m,
# calcPlayerTransSplit.m, computeTermProfit.m, advSingleHand.m) -----
# Recursive evaluation of the same finite, absorbing transitions is equivalent
# to matrix powers for a fixed policy. Each draw increases the all-aces-as-1
# total, so no transient cycles. Store only total/soft states, not full matrices.
# Card values in R: ace=1; face cards=10.
add_card <- function(total,soft,v) {
  t <- total+v; s <- soft
  if(v==1 && !s && t+10<=21) { t <- t+10; s <- TRUE }
  if(t>21 && s) { t <- t-10; s <- FALSE }
  c(total=t,soft=as.integer(s))
}
hand_value <- function(v) {
  t <- sum(v); soft <- any(v==1) && t+10<=21
  c(total=t+10*soft,soft=as.integer(soft))
}
# Terminal dealer distribution indices: totals 17:21, bust, natural BJ.
hand_model <- function(pdf,hli,basic=FALSE) {
  p <- pdf/sum(pdf); stopifnot(length(p)==10, all(is.finite(p)), all(p>=0))
  policy <- make_policy(hli,basic)
  dcache <- new.env(hash=TRUE,parent=emptyenv())
  dealer_end <- function(t,s) {
    key <- paste(t,s,sep=':'); cached <- dcache[[key]]
    if(!is.null(cached)) return(cached)
    ans <- numeric(7)
    if(t>21) ans[6] <- 1 else if(t>=17) ans[t-16] <- 1 else {
      for(v in which(p>0)) { a <- add_card(t,s,v); ans <- ans+p[v]*dealer_end(a[1],a[2]==1) }
    }
    dcache[[key]] <- ans; ans
  }
  dealer <- function(up) {
    ans <- numeric(7)
    for(v in which(p>0)) {
      if((up==1 && v==10)||(up==10 && v==1)) ans[7] <- ans[7]+p[v] else {
        a <- hand_value(c(up,v)); ans <- ans+p[v]*dealer_end(a[1],a[2]==1)
      }
    }
    ans
  }
  up_model <- function(up) {
    dist <- dealer(up); no <- 1-dist[7]
    conditional <- if(no>1e-14) dist[1:6]/no else rep(0,6)
    cache <- new.env(hash=TRUE,parent=emptyenv())
    stand <- function(t) {
      if(t>21) return(-1)
      sum(conditional[1:5]*sign(t-17:21))+conditional[6]
    }
    choose <- function(t,s,initial,pair,can_double,can_split) {
      col <- if(up==1) 10L else up-1L
      code <- if(initial && pair>0 && can_split) policy$pair[if(pair==1) 10L else pair-1L,col] else
        if(s) policy$soft[t-11L,col] else policy$hard[t-3L,col]
      if(code==5L) code <- 3L # no surrender
      if(code==1L && !can_double) code <- 3L
      if(code==2L && !can_double) code <- 0L
      c('Stand','Double','Double','Hit','Split')[code+1L]
    }
    # Return all feasible first-action EVs. After first action, follow the
    # original policy (rather than inventing an independent strategy).
    actions <- function(t,s,initial=FALSE,pair=0L,can_double=initial,can_split=FALSE,extra=Inf) {
      if(t>21) return(c(Bust=-1))
      out <- c(Stand=stand(t))
      if(t>=21) return(out)
      out['Hit'] <- sum(vapply(which(p>0),function(v) {
        a <- add_card(t,s,v); p[v]*value(a[1],a[2]==1,FALSE,0L,FALSE,FALSE,0)
      },numeric(1)))
      if(initial && can_double && extra>=1) out['Double'] <- 2*sum(vapply(which(p>0),function(v) {
        a <- add_card(t,s,v); p[v]*stand(a[1])
      },numeric(1)))
      if(initial && pair>0 && can_split && extra>=1) {
        # No resplits; one card only after splitting aces; no natural payout
        # on split hands. Both post-split expected rewards add by linearity.
        out['Split'] <- 2*sum(vapply(which(p>0),function(v) {
          a <- hand_value(c(pair,v)); p[v]*(if(pair==1) stand(a[1]) else
            value(a[1],a[2]==1,TRUE,0L,extra>=3,FALSE,max(0,extra-1)))
        },numeric(1)))
      }
      out
    }
    value <- function(t,s,initial=FALSE,pair=0L,can_double=initial,can_split=FALSE,extra=Inf) {
      if(t>21) return(-1); if(t==21) return(stand(t))
      key <- paste(t,s,initial,pair,can_double,can_split,min(extra,3),sep=':')
      cached <- cache[[key]]; if(!is.null(cached)) return(cached)
      move <- choose(t,s,initial,pair,can_double && extra>=1,can_split && extra>=1)
      # Evaluate just the prescribed action, not all branches.
      ans <- switch(move, Stand=stand(t),
        Hit=sum(vapply(which(p>0),function(v) { a<-add_card(t,s,v); p[v]*value(a[1],a[2]==1,FALSE,0L,FALSE,FALSE,0) },numeric(1))),
        Double=2*sum(vapply(which(p>0),function(v) p[v]*stand(add_card(t,s,v)[1]),numeric(1))),
        Split=2*sum(vapply(which(p>0),function(v) { a<-hand_value(c(pair,v)); p[v]*(if(pair==1) stand(a[1]) else value(a[1],a[2]==1,TRUE,0L,extra>=3,FALSE,max(0,extra-1))) },numeric(1))))
      cache[[key]] <- ans; ans
    }
    list(dist=dist,conditional=conditional,value=value,actions=actions,choose=choose)
  }
  # Average profit per original unit wager, with US peek before player plays.
  predeal <- function() {
    gain <- 0
    for(up in which(p>0)) {
      m <- up_model(up); bj <- m$dist[7]; g <- 0
      for(a in which(p>0)) for(b in which(p>0)) {
        h <- hand_value(c(a,b)); natural <- h[1]==21
        v <- if(natural) 1.5*(1-bj) else -bj+(1-bj)*m$value(h[1],h[2]==1,TRUE,if(a==b) a else 0L,TRUE,TRUE,Inf)
        g <- g+p[a]*p[b]*v
      }
      gain <- gain+p[up]*g
    }
    gain
  }
  list(dealer=dealer,up=up_model,predeal=predeal,insurance=p[1]*(3*p[10]-1))
}

# ----- Core game: physical finite shoe (without replacement) -----
# The theoretical model freezes probabilities at the beginning of the round;
# the actual game draws from a shuffled physical shoe. Hidden cards never enter
# observed category counts until the dealer reveals them.
new_deck <- function(decks) {
  cards <- expand.grid(rank=c('A',as.character(2:10),'J','Q','K'),suit=c('S','H','D','C'),deck=seq_len(decks),stringsAsFactors=FALSE)
  cards$value <- match(cards$rank,c('A',as.character(2:10),'J','Q','K'))
  cards$value <- pmin(cards$value,10L)
  cards[sample.int(nrow(cards)),,drop=FALSE]
}
category <- function(v) ifelse(v>=2 & v<=6,1L,ifelse(v>=7 & v<=9,2L,3L))
is_natural <- function(cards,split=FALSE) !split && nrow(cards)==2 && hand_value(cards$value)[1]==21
new_hand <- function(cards,bet,split=FALSE) list(cards=cards,bet=bet,split=split,done=FALSE,result='')
fmt <- function(x) sprintf('$%.2f',x)
# Fast internal smoke checks; run with Rscript Blackjack_MC_Shiny.R --self-test.
# The independent Python translation gave basic-strategy EV -0.005704662;
# this provides a regression target for the R port.
self_test <- function() {
  stopifnot(hand_value(c(1,6))[1]==17,add_card(17,TRUE,6)[1]==13,
            add_card(11,FALSE,1)[1]==12,add_card(12,TRUE,1)[1]==13)
  for(d in 2:6) {
    e<-shoe_equilibrium(d); s<-shoe_state(e,c(0,0,0)); stopifnot(abs(sum(s$pdf)-1)<1e-12, s$hli==0)
    cards<-new_deck(d); stopifnot(nrow(cards)==52*d, sum(cards$value==10)==16*d)
  }
  e<-shoe_equilibrium(2); h<-hli_equilibrium(e); stopifnot(abs(sum(h$probability)-1)<1e-9)
  p<-c(rep(1,9),4)/13; m<-hand_model(p,0,TRUE)
  for(up in 1:10) stopifnot(abs(sum(m$dealer(up))-1)<1e-9)
  stopifnot(abs(m$dealer(1)[7]-4/13)<1e-9,abs(m$dealer(10)[7]-1/13)<1e-9)
  g<-m$predeal(); stopifnot(is.finite(g),abs(g-(-0.005704661969060373))<1e-8)
  a<-m$up(6)$actions(11,FALSE,TRUE,0L,TRUE,FALSE,10)
  stopifnot(names(which.max(a))=='Double',all(is.finite(a)))
  a<-m$up(10)$actions(16,FALSE,TRUE,8L,TRUE,TRUE,10)
  stopifnot('Split' %in% names(a),all(is.finite(a)))
  cat('Model smoke tests passed. Basic fresh-shoe advantage:',g,'\n')
}
if('--self-test' %in% commandArgs(trailingOnly=TRUE)) { self_test(); quit(save='no',status=0) }
if(!requireNamespace('shiny',quietly=TRUE)) stop('Install Shiny once: install.packages("shiny")')
library(shiny)

# ----- Shiny UI (all HTML/CSS/JavaScript inline; no image assets) -----
css <- '
:root {color-scheme: light;} body {background:#101e23;color:#e9f2ef;font-family:system-ui,Segoe UI,sans-serif;}
.container-fluid {max-width:1450px;padding:22px;} h1,h2,h3,h4 {font-weight:700;}
h1 {font-size:30px;margin:0 0 5px;} .sub {color:#afc4bf;margin-bottom:18px;}
.panelx {background:#192e33;border:1px solid #35524f;border-radius:14px;padding:16px;margin-bottom:15px;}
.felt {background:radial-gradient(ellipse at top,#23684e,#104231 70%);border:1px solid #45806a;border-radius:18px;padding:20px;min-height:310px;}
.labelx {text-transform:uppercase;font-size:11px;color:#b5d2c6;letter-spacing:1.3px;font-weight:700;}
.stat {display:inline-block;background:#10272a;border:1px solid #34534e;border-radius:9px;padding:8px 12px;margin:3px 4px 4px 0;font-variant-numeric:tabular-nums;}
.cardrow {display:flex;flex-wrap:wrap;gap:6px;margin:9px 0;min-height:88px;align-items:center;}
.playcard {width:62px;height:88px;position:relative;background:#fffdf7;color:#18232a;border:1px solid #cdd4cf;border-radius:8px;box-shadow:0 3px 7px #0004;display:inline-block;flex-shrink:0;}
.playcard.red {color:#c82138;} .corner {position:absolute;left:5px;top:3px;font-size:13px;font-weight:800;line-height:1;text-align:center;}
.corner.bottom {left:auto;top:auto;right:5px;bottom:3px;transform:rotate(180deg);}
.pip {position:absolute;left:0;right:0;top:23px;text-align:center;font-size:35px;line-height:1.2;}
.smallpip {position:absolute;transform:translate(-50%,-50%);line-height:1;}.court {position:absolute;left:17%;right:17%;top:17%;bottom:17%;}.court svg{width:100%;height:100%;}.face {font-size:25px;top:25px;} .back {background:repeating-linear-gradient(45deg,#18365b,#18365b 5px,#264d7a 5px,#264d7a 10px);border:4px solid #fffdf7;}
.seatgrid {display:grid;grid-template-columns:repeat(auto-fit,minmax(205px,1fr));gap:12px;margin-top:16px;}
.seat {background:#0c372b88;border:1px solid #599b7e;border-radius:12px;padding:12px;min-width:0;}
.seat.active {outline:3px solid #edc578;border-color:#edc578;}
.hand {padding:4px 6px;border-radius:8px;margin-top:5px;} .hand.active {background:#edc57820;border:1px solid #edc578;}
.result {color:#f4d49c;font-weight:600;} .muted {color:#a9c3b9;font-size:12px;}
.btn {font-weight:600;margin:3px 3px 3px 0;white-space:normal;} .btn-default {background:#e5efeb;color:#172d2b;border-color:#d0e2dc;}
.btn-primary {background:#24775d;border-color:#4da585;} .btn-primary:hover {background:#1d634e;}
.btn-warning {color:#252018;background:#eac47e;border-color:#eac47e;} .btn-danger {background:#9c4651;border-color:#b8616b;}
.btn:disabled {opacity:.35;cursor:not-allowed;}.form-control {background:#f5f7f5;color:#182e2a;}
.betgrid {display:grid;grid-template-columns:repeat(auto-fit,minmax(115px,1fr));gap:7px;}
.hintbox {background:#12282c;border:1px solid #55766f;border-radius:10px;padding:12px;overflow-wrap:anywhere;}
.hintbox h4 {color:#edc578;margin-top:0;} .hintbox table, .table {color:#e9f2ef!important;} .table>thead>tr>th,.table>tbody>tr>td {border-color:#35524f!important;}
.table-striped>tbody>tr:nth-of-type(odd) {background:#233a3d!important;} .credit {font-size:12px;color:#9cb8b0;} a {color:#8cd8b9;}
@media(max-width:767px){.container-fluid{padding:10px;}.felt{padding:12px;}.playcard{width:51px;height:74px;}.pip{top:19px;font-size:30px;}.cardrow{min-height:74px;}.seatgrid{grid-template-columns:repeat(auto-fit,minmax(150px,1fr));}}
'
suit_symbols <- c(S='\u2660',H='\u2665',D='\u2666',C='\u2663')
# Each court card has a self-contained vector illustration; numeric cards use
# conventional suit pip layouts. No network calls or image downloads.
pip_positions <- list(
  A=rbind(c(50,50)), `2`=rbind(c(50,23),c(50,77)),
  `3`=rbind(c(50,23),c(50,50),c(50,77)),
  `4`=rbind(c(30,23),c(70,23),c(30,77),c(70,77)),
  `5`=rbind(c(30,23),c(70,23),c(50,50),c(30,77),c(70,77)),
  `6`=rbind(c(30,23),c(70,23),c(30,50),c(70,50),c(30,77),c(70,77)),
  `7`=rbind(c(30,23),c(70,23),c(50,36),c(30,50),c(70,50),c(30,77),c(70,77)),
  `8`=rbind(c(30,23),c(70,23),c(50,36),c(30,50),c(70,50),c(50,64),c(30,77),c(70,77)),
  `9`=rbind(c(30,23),c(70,23),c(30,41),c(70,41),c(50,50),c(30,59),c(70,59),c(30,77),c(70,77)),
  `10`=rbind(c(30,23),c(70,23),c(50,32),c(30,41),c(70,41),c(30,59),c(70,59),c(50,68),c(30,77),c(70,77)))
court_art <- function(rank,sym,red) {
  accent<-if(red) '#bc2339' else '#263e70'
  hat<-switch(rank,K='M12 18 L9 6 L18 12 L25 3 L32 12 L41 6 L38 18 Z',
    Q='M12 18 L10 7 L18 13 L25 5 L32 13 L40 7 L38 18 Z',
    J='M10 19 Q9 4 30 8 L42 17 L34 20 Z')
  HTML(sprintf('<svg viewBox="0 0 50 65" role="presentation" xmlns="http://www.w3.org/2000/svg"><rect x="3" y="2" width="44" height="61" rx="2" fill="#f8eed7" stroke="#c1a05e"/><path d="%s" fill="#d9ae52" stroke="#655132" stroke-width="1.2"/><path d="M14 23 Q12 43 10 44 L40 44 Q36 37 36 23" fill="#594534"/><ellipse cx="25" cy="29" rx="10" ry="12" fill="#f3cda4" stroke="#79594d"/><path d="M21 29h1m6 0h1m-7 7q3 2 6 0" stroke="#51372e" stroke-width="1.3" stroke-linecap="round" fill="none"/><path d="M8 60 L10 44 L25 39 L40 44 L42 60 Z" fill="%s" stroke="#493b37"/><path d="M17 43 L25 55 L33 43 M25 55V60" stroke="#d9ae52" stroke-width="3" fill="none"/><text x="25" y="59" font-size="9" text-anchor="middle" fill="#fff">%s</text></svg>',hat,accent,sym))
}
card_ui <- function(card,hidden=FALSE) {
  if(hidden) return(tags$div(class='playcard back',role='img',`aria-label`='Face-down card'))
  r <- card$rank[1]; s <- card$suit[1]; sym <- unname(suit_symbols[s])
  face <- r %in% c('J','Q','K')
  tags$div(class=paste('playcard',if(s %in% c('H','D')) 'red' else ''),role='img',`aria-label`=paste(r,s),
    tags$div(class='corner',r,tags$br(),sym),
    if(face) tags$div(class='court',court_art(r,sym,s %in% c('H','D'))) else {
      pos<-pip_positions[[r]]
      lapply(seq_len(nrow(pos)),function(i) tags$span(class='smallpip',
        style=sprintf('left:%s%%;top:%s%%;font-size:%spx;%s',pos[i,1],pos[i,2],if(r=='A') 34 else 15,if(pos[i,2]>50) 'transform:translate(-50%,-50%) rotate(180deg);' else ''),sym))
    },
    tags$div(class='corner bottom',r,tags$br(),sym))
}
card_row <- function(cards,hide=FALSE) {
  tags$div(class='cardrow',if(nrow(cards)) lapply(seq_len(nrow(cards)),function(i) card_ui(cards[i,,drop=FALSE],hide && i==2L)))
}

ui <- fluidPage(
  tags$head(tags$meta(name='viewport',content='width=device-width, initial-scale=1'),tags$style(HTML(css)),
    tags$script(HTML("Shiny.addCustomMessageHandler('enableButtons', function(x) { Object.keys(x).forEach(function(k) { var el=document.getElementById(k); if(el) el.disabled=!x[k]; }); });"))),
  tags$div(
    style = "display:flex; justify-content:space-between;
           align-items:center; margin-bottom:18px;",
    
    tags$div(
      tags$h1('Blackjack | Markov Chain Lab'),
      tags$p(class='sub',
             'Interactive Stats 400 demonstration · local play-money only · no real wagers')
    ),
    
    tags$img(
      src = "https://silhouettesfree.com/movies/despicable-me/gru-silhouette-image-2.png",
      alt = "Gru",
      style = "width:55px; height:auto;
             margin-right:10px;
             filter:invert(1);"
    )
  ),
  fluidRow(
    column(3,
      tags$div(class='panelx',tags$h4('Session settings'),
        selectInput('decks','Decks',choices=2:6,selected=4),
        selectInput('players','Players',choices=setNames(1:4,c('1 · Single player','2 · Local multiplayer','3 · Local multiplayer','4 · Local multiplayer')),selected=1),
        sliderInput('money','Starting credits per player ($)',20,500,100,step=1),
        actionButton('start','Start',class='btn-primary'),actionButton('pause','Pause / Resume',class='btn-warning'),actionButton('end','End session',class='btn-danger'),
        tags$p(class='muted','Settings apply when starting a new session. Players share one shoe and take turns.')),
      tags$div(class='panelx',tags$h4('Round controls'),uiOutput('bets'),
        actionButton('deal','Deal next round',class='btn-primary'),
        tags$hr(),actionButton('hit','Hit'),actionButton('stand','Stand'),actionButton('double','Double'),actionButton('split','Split'),
        tags$br(),actionButton('insurance_yes','Take insurance'),actionButton('insurance_no','Pass insurance'),
        tags$hr(),actionButton('hint','Markov hint',class='btn-warning'),
        tags$p(class='muted','Hints use a fixed-distribution hand model and the shoe equilibrium; they are not guarantees.')),
      tags$div(class='panelx',tags$h4('Table rules'),tags$p('Dealer stands on soft 17; blackjack pays 3:2; double on two cards; one split per player; double after split allowed; split aces receive one card; no surrender; optional insurance pays 2:1.'))),
    column(9,
      tags$div(class='panelx',uiOutput('status')),
      tags$div(class='felt',uiOutput('table')),
      tags$div(class='panelx',style='margin-top:15px',tags$h4('Markov analysis'),uiOutput('hint_output')),
      fluidRow(column(6,tags$div(class='panelx',tags$h4('Shoe equilibrium'),plotOutput('equilibrium_plot',height='230px'),tags$p(class='muted','Stationary HLI distribution of the paper’s card-level reshuffle model. Marker = current model state.'))),
               column(6,tags$div(class='panelx',tags$h4('Session results'),tableOutput('summary'),plotOutput('history_plot',height='190px')))),
      tags$p(class='credit','Adapted from Blackjack Markov Chain Toolbox v1.0 (2009), Michael B. Wakin and Christopher J. Rozell. ',tags$a(href='https://repository.rice.edu/items/1abebb50-9696-465c-8ed5-7c4a6f33c890','Original paper'), ' · ',tags$a(href='https://creativecommons.org/licenses/by/3.0/','CC BY 3.0'),'. R/Shiny adaptation with recursive absorption and finite-shoe game logic.'))))

# ----- Session controller -----
server <- function(input,output,session) {
  st <- new.env(parent=emptyenv())
  st$phase <- 'idle'; st$paused <- FALSE; st$message <- 'Choose settings and press Start.'
  rev <- reactiveVal(0L); hint <- reactiveVal(NULL)
  touch <- function(clear=TRUE) { if(clear) hint(NULL); rev(isolate(rev())+1L) }
  ready <- function(phase) !st$paused && st$phase %in% phase
  live <- function() st$phase %in% c('betting','insurance','playing','complete')
  notify <- function(msg) showNotification(msg,type='warning',duration=4)
  reset_shoe <- function() {
    st$shoe <- new_deck(st$decks); st$pos <- 0L; st$observed <- c(0L,0L,0L)
    st$cut <- sample(0:st$eq$N,1,prob=st$eq$cut); st$shoe_num <- st$shoe_num+1L
  }
  # Never deal a new shoe mid-hand. At exhaustion, cancel and refund the round.
  draw <- function(visible=TRUE) {
    if(st$pos>=nrow(st$shoe)) stop('Shoe exhausted; round canceled and all stakes refunded.')
    st$pos <- st$pos+1L; card <- st$shoe[st$pos,,drop=FALSE]
    if(visible) { k<-category(card$value); st$observed[k]<-st$observed[k]+1L }
    card
  }
  reveal <- function() {
    if(!st$hole_visible && nrow(st$dealer)>=2L) {
      k<-category(st$dealer$value[2]); st$observed[k]<-st$observed[k]+1L; st$hole_visible<-TRUE
    }
  }
  # A completed round is the only unit recorded in session statistics.
  cancel_round <- function() {
    if(st$phase %in% c('insurance','playing')) {
      st$bank <- st$round_start_bank; reveal()
      for(i in seq_len(st$players)) for(j in seq_along(st$hands[[i]])) {
        st$hands[[i]][[j]]$result <- 'Canceled'; st$hands[[i]][[j]]$done <- TRUE
      }
    }
  }
  safely <- function(f) tryCatch(f(),error=function(e) {
    cancel_round(); st$phase<-'complete'; st$message<-conditionMessage(e); touch(); notify(st$message)
  })
  observeEvent(input$start,{
    if(live()) return(notify('End the current session before starting another.'))
    st$decks<-as.integer(input$decks); st$players<-as.integer(input$players); st$initial<-as.numeric(input$money)
    st$eq<-shoe_equilibrium(st$decks); st$hist<-hli_equilibrium(st$eq)
    st$bank<-rep(st$initial,st$players); st$pref<-rep(1,st$players); st$round<-0L; st$shoe_num<-0L
    st$wins<-st$losses<-st$pushes<-integer(st$players); st$history<-matrix(st$bank,nrow=1)
    st$hands<-replicate(st$players,list(),simplify=FALSE); st$dealer<-new_deck(1)[FALSE,]; st$hole_visible<-TRUE
    st$insurance<-numeric(st$players); st$in_play<-integer(); st$active<-0L; st$hand_index<-0L
    st$paused<-FALSE; st$phase<-'betting'; reset_shoe(); st$snapshot<-shoe_state(st$eq,st$observed); st$model<-NULL
    st$message<-'Set a simulated wager for each player, then deal.'; touch()
  })
  observeEvent(input$pause,{
    if(!live()) return()
    st$paused<-!st$paused; touch(clear=FALSE)
  })
  observeEvent(input$end,{
    if(!live()) return()
    cancel_round(); st$active<-0L; st$hand_index<-0L; st$paused<-FALSE; st$phase<-'ended'; st$message<-'Session ended. Any unfinished round was canceled and its wagers refunded.'; touch()
  })
  output$bets <- renderUI({
    rev(); if(!st$phase %in% c('betting','complete')) return(NULL)
    tags$div(class='betgrid',lapply(seq_len(st$players),function(i) {
      # A player with less than one credit sits out; no negative balances.
      id<-paste0('bet',i); prev<-isolate(input[[id]])
      v<-if(is.null(prev)||!is.finite(prev)) st$pref[i] else prev
      if(st$bank[i]<1) return(tags$p(class='muted',paste('P',i,'sits out (',fmt(st$bank[i]),')')))
      numericInput(id,paste('Player',i,'wager'),value=max(1,min(floor(st$bank[i]),floor(v))),min=1,max=floor(st$bank[i]),step=1)
    }))
  })
  # Settlement: stakes have already been debited. Return stake + net profit.
  finish_round <- function() {
    reveal(); dealer_bj<-is_natural(st$dealer)
    all_done <- all(vapply(st$hands,function(hs) all(vapply(hs,function(h) hand_value(h$cards$value)[1]>21 || is_natural(h$cards,h$split),logical(1))),logical(1)))
    if(!dealer_bj && !all_done) while(hand_value(st$dealer$value)[1]<17) st$dealer<-rbind(st$dealer,draw())
    dt<-hand_value(st$dealer$value)[1]
    for(i in st$in_play) {
      if(st$insurance[i]>0 && dealer_bj) st$bank[i]<-st$bank[i]+3*st$insurance[i]
      for(j in seq_along(st$hands[[i]])) {
        h<-st$hands[[i]][[j]]; t<-hand_value(h$cards$value)[1]; natural<-is_natural(h$cards,h$split)
        mult<-if(t>21) -1 else if(dealer_bj) { if(natural) 0 else -1 } else if(natural) 1.5 else if(dt>21 || t>dt) 1 else if(t<dt) -1 else 0
        st$bank[i]<-st$bank[i]+h$bet*(1+mult)
        h$done<-TRUE; h$result<-paste0(if(mult>0) 'Win ' else if(mult<0) 'Loss ' else 'Push ',if(mult==0) '' else fmt(abs(mult*h$bet)))
        st$hands[[i]][[j]]<-h
        if(mult>0) st$wins[i]<-st$wins[i]+1L else if(mult<0) st$losses[i]<-st$losses[i]+1L else st$pushes[i]<-st$pushes[i]+1L
      }
    }
    st$round<-st$round+1L; st$history<-rbind(st$history,st$bank)
    st$active<-0L; st$hand_index<-0L; st$phase<-'complete'
    st$message<-if(all(st$bank<1)) 'All players have less than one credit. End the session to restart.' else 'Round complete. Set wagers and deal again.'
    touch()
  }
  advance <- function() {
    for(i in st$in_play) for(j in seq_along(st$hands[[i]])) {
      h<-st$hands[[i]][[j]]
      if(!h$done && hand_value(h$cards$value)[1]>=21) {
        h$done<-TRUE; st$hands[[i]][[j]]<-h
      }
      if(!h$done) { st$active<-i; st$hand_index<-j; st$phase<-'playing'; st$message<-paste('Player',i,'— hand',j); touch(); return(invisible(NULL)) }
    }
    finish_round()
  }
  after_insurance <- function() {
    if(is_natural(st$dealer)) finish_round() else advance()
  }
  observeEvent(input$deal,{
    if(!ready(c('betting','complete'))) return()
    if(all(st$bank<1)) return(notify('No player has enough credits to deal.'))
    bets<-vapply(seq_len(st$players),function(i) {
      v<-input[[paste0('bet',i)]]; if(is.null(v)) v<-st$pref[i]
      if(st$bank[i]<1) 0 else if(!is.finite(v)||v<1||v!=floor(v)||v>st$bank[i]) NA_real_ else v
    },numeric(1))
    if(anyNA(bets)) return(notify('Each active wager must be a whole number from 1 to the available credits.'))
    safely(function(){
      # Actual game reshuffles only between rounds, unlike card-level model.
      # Keep a 40-card reserve for multiplayer; a rare exhaustion is refunded.
      if(st$pos>=st$cut || st$eq$N-st$pos<40L) reset_shoe()
      st$snapshot<-shoe_state(st$eq,st$observed); st$model<-NULL
      st$round_start_bank<-st$bank; st$pref<-pmax(1,bets); st$in_play<-which(bets>0)
      st$hands<-replicate(st$players,list(),simplify=FALSE); st$insurance<-numeric(st$players)
      st$bank<-st$bank-bets; st$phase<-'playing'; st$dealer<-st$shoe[FALSE,]; st$hole_visible<-FALSE
      for(i in st$in_play) st$hands[[i]]<-list(new_hand(draw(),bets[i]))
      st$dealer<-draw()
      for(i in st$in_play) st$hands[[i]][[1]]$cards<-rbind(st$hands[[i]][[1]]$cards,draw())
      st$dealer<-rbind(st$dealer,draw(FALSE))
      if(st$dealer$value[1]==1) {
        st$phase<-'insurance'; st$insurance_index<-1L; st$active<-st$in_play[1]; st$hand_index<-1L
        st$message<-paste('Player',st$active,'— dealer shows ace; choose insurance or pass.'); touch()
      } else after_insurance()
    })
  })
  insurance_step <- function(take) {
    if(!ready('insurance')) return()
    i<-st$active; stake<-st$hands[[i]][[1]]$bet/2
    if(take && st$bank[i]<stake) return(notify('Insufficient credits for insurance. Choose Pass.'))
    if(take) {st$bank[i]<-st$bank[i]-stake; st$insurance[i]<-stake}
    st$insurance_index<-st$insurance_index+1L
    if(st$insurance_index>length(st$in_play)) after_insurance() else {
      st$active<-st$in_play[st$insurance_index]; st$message<-paste('Player',st$active,'— insurance decision'); touch()
    }
  }
  observeEvent(input$insurance_yes,safely(function() insurance_step(TRUE)))
  observeEvent(input$insurance_no,safely(function() insurance_step(FALSE)))
  can_split <- function(h,i) nrow(h$cards)==2L && !h$split && h$cards$value[1]==h$cards$value[2] && st$bank[i]>=h$bet
  can_double <- function(h,i) nrow(h$cards)==2L && st$bank[i]>=h$bet
  act <- function(move) {
    if(!ready('playing')) return()
    i<-st$active; j<-st$hand_index; h<-st$hands[[i]][[j]]
    if(move=='split') {
      if(!can_split(h,i)) return(notify('Split requires a pair, no previous split, and sufficient credits.'))
      st$bank[i]<-st$bank[i]-h$bet
      h1<-new_hand(rbind(h$cards[1,,drop=FALSE],draw()),h$bet,TRUE)
      h2<-new_hand(rbind(h$cards[2,,drop=FALSE],draw()),h$bet,TRUE)
      if(h$cards$value[1]==1) {h1$done<-TRUE; h2$done<-TRUE}
      st$hands[[i]]<-list(h1,h2)
    } else {
      if(move=='double') {
        if(!can_double(h,i)) return(notify('Double requires two cards and sufficient credits.'))
        st$bank[i]<-st$bank[i]-h$bet; h$bet<-2*h$bet; h$cards<-rbind(h$cards,draw()); h$done<-TRUE
      } else if(move=='hit') {h$cards<-rbind(h$cards,draw()); h$done<-hand_value(h$cards$value)[1]>=21} else if(move=='stand') h$done<-TRUE
      st$hands[[i]][[j]]<-h
    }
    advance()
  }
  observeEvent(input$hit,safely(function() act('hit')))
  observeEvent(input$stand,safely(function() act('stand')))
  observeEvent(input$double,safely(function() act('double')))
  observeEvent(input$split,safely(function() act('split')))
  # Button states and server-side guards both enforce pause/end/turn rules.
  observe({
    rev(); b<-list(start=!live(),pause=live(),end=live(),deal=ready(c('betting','complete')) && any(st$bank>=1),
      hit=ready('playing'),stand=ready('playing'),double=FALSE,split=FALSE,insurance_yes=FALSE,insurance_no=ready('insurance'),hint=ready(c('betting','complete','playing','insurance')))
    if(ready('playing')) {h<-st$hands[[st$active]][[st$hand_index]]; b$double<-can_double(h,st$active); b$split<-can_split(h,st$active)}
    if(ready('insurance')) b$insurance_yes<-st$bank[st$active]>=st$hands[[st$active]][[1]]$bet/2
    session$sendCustomMessage('enableButtons',b)
  })
  # For pre-deal, the game will reset at the cut/reserve; model that new shoe
  # without peeking at the next card or at the dealer's hidden card.
  prospective <- function() {
    if(st$phase %in% c('betting','complete')) {
      if(st$pos>=st$cut || st$eq$N-st$pos<40L) shoe_state(st$eq,c(0L,0L,0L)) else shoe_state(st$eq,st$observed)
    } else st$snapshot
  }
  observeEvent(input$hint,{
    if(!ready(c('betting','complete','playing','insurance'))) return()
    tryCatch({
      ss<-prospective(); pre<-st$phase %in% c('betting','complete')
      model<-if(pre) hand_model(ss$pdf,ss$hli) else {
        if(is.null(st$model)) st$model<-hand_model(ss$pdf,ss$hli)
        st$model
      }
      hli_bin<-round(ss$hli); hist<-st$hist
      context<-list(hli=ss$hli,lmh=ss$lmh,remaining=ss$R,pi=ss$pi,depth=ss$depth_mu,
        tail=sum(hist$probability[hist$hli>=hli_bin]),hazard=ss$hazard)
      if(pre) {
        # Original BJMCmainScript/setStrategy comparison. This is historical
        # simulation exposure only, not a bankroll-risk optimization.
        a<-model$predeal(); ins<-if(ss$hli>8) model$insurance/2 else 0
        bet<-min(5,max(1,floor(ss$hli/2)))
        hint(list(type='bet',context=context,adv=a,ins=ins,bet=bet,expected=(a+ins)*bet,
                  allowed=pmin(bet,floor(st$bank))))
      } else if(st$phase=='insurance') {
        v<-3*ss$pdf[10]-1
        hint(list(type='insurance',context=context,ev=v,source=ss$hli>8,afford=st$bank[st$active]>=st$hands[[st$active]][[1]]$bet/2))
      } else {
        i<-st$active; h<-st$hands[[i]][[st$hand_index]]; t<-hand_value(h$cards$value)
        pair<-if(nrow(h$cards)==2L && h$cards$value[1]==h$cards$value[2]) h$cards$value[1] else 0L
        m<-model$up(st$dealer$value[1]); extra<-st$bank[i]/h$bet
        ev<-m$actions(t[1],t[2]==1,nrow(h$cards)==2L,pair,can_double(h,i),can_split(h,i),extra)
        original<-m$choose(t[1],t[2]==1,nrow(h$cards)==2L,pair,can_double(h,i),can_split(h,i))
        hint(list(type='play',context=context,ev=sort(ev,decreasing=TRUE),original=original,player=i,hand=st$hand_index))
      }
    },error=function(e) notify(paste('Model error:',conditionMessage(e))))
  })
  output$hint_output<-renderUI({
    h<-hint(); if(is.null(h)) return(tags$p(class='muted','Press Markov hint before dealing or during your turn to compare model-based expected outcomes.'))
    x<-h$context; pct<-function(z) sprintf('%.3f%%',100*z)
    method2<-tags$div(tags$h4('Method 2 · Shoe equilibrium'),
      tags$p(sprintf('L/M/H played = %d / %d / %d · %d cards remaining · HLI = %.2f',x$lmh[1],x$lmh[2],x$lmh[3],x$remaining,x$hli)),
      tags$p(class='muted',sprintf('Stationary probability of this state: %.6g; depth mass: %s; long-run HLI at or above this rounded index: %s.',x$pi,pct(x$depth),pct(x$tail))),
      tags$p(class='muted','Equilibrium weights describe how often states occur. The HLI and the state’s grouped card PDF feed Method 1; equilibrium frequency is not a second independent prediction.'))
    method1<-if(h$type=='bet') tags$div(tags$h4('Method 1 · Before the deal'),
        tags$p(sprintf('Expected hand profit per $1 initial credit: %+.4f (%s).',h$adv,pct(h$adv))),
        tags$p(sprintf('Historical insurance adjustment: %+.5f per unit; historical Thorp simulated wager: %d unit(s).',h$ins,h$bet)),
        tags$p(sprintf('Modeled expected gain at that historical wager: %+.4f credits per hand.',h$expected)),
        tags$p(paste('Historical wager capped by available play credits:',paste(sprintf('P%d = %s',seq_along(h$allowed),fmt(h$allowed)),collapse=' · '))),
        tags$p(class='muted','The wager rule is the original 1–5 unit rule, not a proven optimal bankroll allocation. Negative EV remains negative even if a wager is increased.')) else if(h$type=='insurance') tags$div(tags$h4('Method 1 · Insurance'),
        tags$p(sprintf('Conditional expected net profit per insurance credit: %+.4f. Historical HLI rule: %s.',h$ev,if(h$source) 'take' else 'pass')),
        tags$p(if(!h$afford) 'Insufficient credits for insurance.' else paste('Higher modeled EV:',if(h$ev>0) 'Take insurance' else 'Pass insurance'))) else tags$div(tags$h4(sprintf('Method 1 · Player %d / hand %d',h$player,h$hand)),
        tags$p(tags$strong(paste('Highest modeled first-action EV:',names(h$ev)[1]))),
        tags$p(paste('Original Thorp table action:',h$original)),
        tags$table(class='table table-condensed',tags$thead(tags$tr(tags$th('Action'),tags$th('Expected net credits / initial unit'))),tags$tbody(lapply(seq_along(h$ev),function(i) tags$tr(tags$td(names(h$ev)[i]),tags$td(sprintf('%+.4f',h$ev[i])))))),
        tags$p(class='muted','Compares feasible actions conditional on no dealer blackjack, with the original HLI policy for subsequent decisions. Split doubles are conservatively budgeted.'))
    tags$div(class='hintbox',method1,tags$hr(),method2,tags$p(class='muted','Model probabilities are frozen at the start of the round, as in the paper. Gameplay uses actual draws without replacement. No financial advice; simulated credits only.'))
  })
  output$status<-renderUI({
    rev(); if(st$phase=='idle') return(tags$p(st$message))
    tags$div(tags$div(class='labelx',if(st$paused) 'Paused' else st$phase),tags$h4(st$message),
      tags$span(class='stat',paste('Round',st$round)),tags$span(class='stat',paste('Shoe',st$shoe_num)),
      tags$span(class='stat',paste(st$decks,'decks')),tags$span(class='stat',paste(st$eq$N-st$pos,'cards left')),tags$span(class='stat',paste(st$players,'players')))
  })
  output$table<-renderUI({
    rev(); if(st$phase=='idle') return(tags$div(tags$h3('Table ready'),tags$p('Start a session to deal cards.')))
    dc<-st$dealer; shown<-if(!st$hole_visible && nrow(dc)>=2) dc[-2,,drop=FALSE] else dc
    tags$div(tags$div(class='labelx','Dealer'),card_row(dc,!st$hole_visible),
      if(nrow(shown)) tags$div(class='muted',paste(if(st$hole_visible) 'Total' else 'Visible total',hand_value(shown$value)[1])),
      tags$div(class='seatgrid',lapply(seq_len(st$players),function(i) {
        active<-i==st$active && st$phase %in% c('playing','insurance')
        tags$div(class=paste('seat',if(active) 'active' else ''),tags$div(class='labelx',paste('Player',i,if(active) '· your turn' else '')),
          tags$h4(fmt(st$bank[i])),tags$span(class='muted','Available play credits'),
          if(!length(st$hands[[i]])) tags$p(class='muted','Waiting for cards') else lapply(seq_along(st$hands[[i]]),function(j) {
            h<-st$hands[[i]][[j]]; hv<-hand_value(h$cards$value)
            tags$div(class=paste('hand',if(active && j==st$hand_index) 'active' else ''),
              tags$div(class='muted',paste('Hand',j,'· wager',fmt(h$bet),'· total',hv[1],if(hv[2]==1) '(soft)' else '')),
              card_row(h$cards),tags$div(class='result',if(nzchar(h$result)) h$result else if(hv[1]>21) 'Bust' else if(is_natural(h$cards,h$split)) 'Blackjack' else if(h$done) 'Complete' else ''))
          }),if(st$insurance[i]>0) tags$p(class='muted',paste('Insurance:',fmt(st$insurance[i]))))
      })))
  })
  output$equilibrium_plot<-renderPlot({
    rev(); req(st$phase!='idle'); h<-st$hist
    par(mar=c(4,4,1,1),bg='#192e33',fg='#dce9e4',col.axis='#dce9e4',col.lab='#dce9e4')
    plot(h$hli,h$probability,type='h',lwd=3,col='#86c5ab',xlab='High-Low Index (HLI)',ylab='Stationary probability',xlim=c(-100,100),bty='l')
    ss<-prospective(); abline(v=ss$hli,col='#edc578',lwd=2,lty=2)
  })
  output$summary<-renderTable({
    rev(); req(st$phase!='idle'); settled<-if(nrow(st$history)>0) st$history[nrow(st$history),] else st$bank
    data.frame(Player=seq_len(st$players),Credits=fmt(st$bank),`Settled P/L`=sprintf('%+.2f',settled-st$initial),Wins=st$wins,Losses=st$losses,Pushes=st$pushes,check.names=FALSE)
  },striped=TRUE,spacing='xs')
  output$history_plot<-renderPlot({
    rev(); req(st$phase!='idle'); hist<-st$history
    par(mar=c(4,4,1,1),bg='#192e33',fg='#dce9e4',col.axis='#dce9e4',col.lab='#dce9e4')
    cols<-c('#86c5ab','#edc578','#87b6e9','#e7a0ab')[seq_len(st$players)]
    matplot(0:(nrow(hist)-1),hist,type='o',pch=16,lty=1,col=cols,xlab='Completed rounds',ylab='Play credits',bty='l',xlim=c(0,max(1,nrow(hist)-1)))
    abline(h=st$initial,col='#a9c3b9',lty=3)
    if(st$players>1) legend('topright',legend=paste('P',seq_len(st$players)),col=cols,lty=1,pch=16,text.col='#dce9e4',bty='n',cex=.8)
  })
}

# Launch in the default browser or RStudio viewer. No external services.
shiny::runApp(shinyApp(ui=ui,server=server),launch.browser=TRUE)
