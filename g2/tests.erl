-module(tests).
-export([run/0]).

run() ->
    true=login_manager:start(),
    success_create=login_manager:create_account(ric,123),
    success_create=login_manager:create_account(jon,555),
    success_create=login_manager:create_account(tuc,935),
    success_login=login_manager:login(ric,123),
    success_login=login_manager:login(jon,555),
    success_login=login_manager:login(tuc,935),
    invalid_username=login_manager:logout(jose,935),
    invalid_passwd=login_manager:logout(tuc,999),
    success_logout=login_manager:logout(tuc,935),
    not_logged_in=login_manager:logout(tuc,935),
    [jon,ric]=login_manager:online(),
    success_login=login_manager:login(tuc,935),
    [jon,ric,tuc]=login_manager:online(),
    true=login_manager:stop().
