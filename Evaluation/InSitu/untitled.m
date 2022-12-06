k = 1:20
% figure

lambdas = 400:850;
n_DMF = 1.4764-6.2707e4./lambda.^2 + 1.3755e10./lambda.^4;
n_DMSO = sqrt(1+0.04419*(lambda/1000).^2./((lambda/1000).^2 - 0.046390067309) + 1.09101*(lambda/1000).^2./((lambda/1000).^2 - 0.01221543949));
n = (4*n_DMF + n_DMSO)/5;

lambdaList = [432 454 483 515 551 598];
lambdaIndex = [];
for i=1:length(lambdaList)
[~,lambdaIndex(i)] = min(abs(lambda-lambdaList(i)));
end
aaa = [];
for i=1:length(lambdaList)
wlS = lambdaIndex(i);
aaa(i,:) = (k*lambda(wlS))./(2*n(wlS));
end
% figure
% for i=1:length(lambdaList)
% plot(aaa(i,:),'o')
% hold on
% end

figure
for i=1:length(lambdaList)
    plot(k+i-1, aaa(i,:), 'o')
    hold on
end