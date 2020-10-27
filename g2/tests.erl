-module(tests).
-export([run/0]).

run() ->
    c:c(login_manager),
    login_manager:start(),
    login_manager:create_account(ric,123),
    login_manager:create_account(jon,555),
    login_manager:create_account(tuc,935),
    login_manager:login(ric,123),
    login_manager:login(jon,555),
    login_manager:login(tuc,935),
    On=login_manager:online(),
    login_manager:stop(),
    On.
