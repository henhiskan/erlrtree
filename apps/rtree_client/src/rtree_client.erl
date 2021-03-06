% Copyright 2013 Carlos Roman
%
% Licensed under the Apache License, Version 2.0 (the "License"); you may not
% use this file except in compliance with the License. You may obtain a copy of
% the License at
%
%   http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
% WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
% License for the specific language governing permissions and limitations under
% the License.

%%%----------------------------------------------------------------
%%% @author Carlos Roman <caroman@gmail.com>
%%% @doc
%%%   Escript with rtree client
%%% @copyright 2013 Carlos Roman
%%% @end
%%%----------------------------------------------------------------
-module(rtree_client).
-export([main/1]).
-mode(compile).

-define(ESCRIPT, filename:basename(escript:script_name())).
-compile([{parse_transform, lager_transform}]).


%% ====================================================================
%% Public API
%% ====================================================================

%%------------------------------------------------------------------------------
%% @doc
%% Entry point
%%
%% @spec main(Args) -> atom(ok)
%% @end
%%------------------------------------------------------------------------------
main(Args) ->
    os:putenv("ESCRIPT", "1"),
    lager:start(),
    lager:set_loglevel(lager_console_backend, warning),
    case catch(run(Args)) of
        ok ->
            ok;
        Error ->
            %% Dump this error to console
            lager:error("Uncaught error processing args: ~p", [Error]),
            delayed_halt(1)
    end.

%% ====================================================================
%% Parser
%% ====================================================================

%%------------------------------------------------------------------------------
%% @doc
%% Main usage function
%%
%% @spec usage() -> ok
%% @end
%%------------------------------------------------------------------------------
usage() ->
    OptSpecList = main_option_spec_list(),
    getopt:usage(OptSpecList, "rtree_client",
                 "command_args -- [options]").

%%------------------------------------------------------------------------------
%% @doc
%% Command create parser specific usage
%%
%% @spec command_create_usage() -> ok
%% @end
%%------------------------------------------------------------------------------
command_create_usage() ->
    OptSpecList = command_create_option_spec_list(),
    getopt:usage(OptSpecList, "rtree_client create --").

%%------------------------------------------------------------------------------
%% @doc
%% Command build parser specific usage
%%
%% @spec command_build_usage() -> ok
%% @end
%%------------------------------------------------------------------------------
command_build_usage() ->
    OptSpecList = command_build_option_spec_list(),
    getopt:usage(OptSpecList, "rtree_client build --").

%%------------------------------------------------------------------------------
%% @doc
%% Command delete parser specific usage
%%
%% @spec command_delete_usage() -> ok
%% @end
%%------------------------------------------------------------------------------
command_delete_usage() ->
    OptSpecList = command_delete_option_spec_list(),
    getopt:usage(OptSpecList, "rtree_client delete --").

%%------------------------------------------------------------------------------
%% @doc
%% Command doall parser specific usage
%%
%% @spec command_doall_usage() -> ok
%% @end
%%------------------------------------------------------------------------------
command_doall_usage() ->
    OptSpecList = command_doall_option_spec_list(),
    getopt:usage(OptSpecList, "rtree_client doall --").

%%------------------------------------------------------------------------------
%% @doc
%% Command filter parser specific usage
%%
%% @spec command_filter_usage() -> ok
%% @end
%%------------------------------------------------------------------------------
command_filter_usage() ->
    OptSpecList = command_filter_option_spec_list(),
    getopt:usage(OptSpecList, "rtree_client filter --").

%%------------------------------------------------------------------------------
%% @doc
%% Command intersects parser specific usage
%%
%% @spec command_intersects_usage() -> ok
%% @end
%%------------------------------------------------------------------------------
command_intersects_usage() ->
    OptSpecList = command_intersects_option_spec_list(),
    getopt:usage(OptSpecList, "rtree_client intersects --").

%%------------------------------------------------------------------------------
%% @doc
%% Command insert parser specific usage
%%
%% @spec command_insert_usage() -> ok
%% @end
%%------------------------------------------------------------------------------
command_insert_usage() ->
    OptSpecList = command_insert_option_spec_list(),
    getopt:usage(OptSpecList, "rtree_client insert --").

%%------------------------------------------------------------------------------
%% @doc
%% Command load parser specific usage
%%
%% @spec command_load_usage() -> ok
%% @end
%%------------------------------------------------------------------------------
command_load_usage() ->
    OptSpecList = command_load_option_spec_list(),
    getopt:usage(OptSpecList, "rtree_client load --").

%%------------------------------------------------------------------------------
%% @doc
%% Command lookup parser specific usage
%%
%% @spec command_lookup_usage() -> ok
%% @end
%%------------------------------------------------------------------------------
command_lookup_usage() ->
    OptSpecList = command_lookup_option_spec_list(),
    getopt:usage(OptSpecList, "rtree_client lookup --").


%%------------------------------------------------------------------------------
%% @doc
%% Main option specification list
%%
%% @spec main_option_spec_list() -> ok
%% @end
%%------------------------------------------------------------------------------
main_option_spec_list() ->
    %Jobs = ?DEFAULT_JOBS,
    %JobsHelp = io_lib:format(
    %    "Number of concurrent workers a command may use. Default: ~B",
    %    [Jobs]),
    VerboseHelp = "Verbosity level (debug, info, warning, error). Default: warning",
    CommandsHelp = "Execute command: create, insert, load, build, intersects,
        filter, lookup, delete. ",
    [
     %% {Name, ShortOpt, LongOpt, ArgSpec, HelpMsg}
     {help,         $h,         "help",         undefined,
        "Show the program options"},
     {verbose,      $v,         "verbose",      {atom, warning}, VerboseHelp},
     %%{version,      $V,         "version",      undefined,
     %%   "Show version information"},
     {node_name,    $n,         "node_name",    {atom, node_name()},
        "Set the client node's <name|sname>. Default rtree_client."},
     {remote_node,  $r,         "remote_node",  {atom,
        node_sname("rtree_server")},
        "Node <sname> to connect to. Default name rtree_server."},
     {cookie,       $c,         "cookie",       {atom, rtree_server},
        "Set cookie. Default rtree_server."},
     {timeout,      $t,         "timeout",      {integer, 10},
        "Timeout for response. Default 10 seconds. If is 0 then none is set."},
     {command,     undefined,   undefined,    atom, CommandsHelp}
    ].

%%------------------------------------------------------------------------------
%% @doc
%% Command create specific option specification list
%%
%% @spec command_create_option_spec_list() -> ok
%% @end
%%------------------------------------------------------------------------------
command_create_option_spec_list() ->
    [
     %% {Name, ShortOpt, LongOpt, ArgSpec, HelpMsg}
     {help,         $h,         "help",         undefined,
        "Show the program options"},
     {tree_name,    undefined,  undefined,      atom,
        "Tree name for rtree server (gen_server and ets)."}
    ].

%%------------------------------------------------------------------------------
%% @doc
%% Command insert specific option specification list
%%
%% @spec command_insert_option_spec_list() -> ok
%% @end
%%------------------------------------------------------------------------------
command_insert_option_spec_list() ->
    [
     %% {Name, ShortOpt, LongOpt, ArgSpec, HelpMsg}
     {help,         $h,         "help",         undefined,
        "Show the program options"},
     {tree_name,    undefined,  undefined,      atom,
        "Tree name for rtree server (gen_server and ets)."},
     {dsn,    undefined,  undefined,      string,
        "Data source name."},
     {idindex,    undefined,  undefined,      integer,
        "Field position (1-based) to be used as unique index."}
    ].


%%------------------------------------------------------------------------------
%% @doc
%% Command load specific option specification list
%%
%% @spec command_load_option_spec_list() -> ok
%% @end
%%------------------------------------------------------------------------------
command_load_option_spec_list() ->
    [
     %% {Name, ShortOpt, LongOpt, ArgSpec, HelpMsg}
     {help,         $h,         "help",         undefined,
        "Show the program options"},
     {tree_name,    undefined,  undefined,      atom,
        "Tree name for rtree server (gen_server and ets)."},
     {dsn,    undefined,  undefined,      string,
            "Data source name."},
     {idindex,    undefined,  undefined,      integer,
        "Field position (1-based) to be used as unique index."}
    ].

%%------------------------------------------------------------------------------
%% @doc
%% Command build specific option specification list
%%
%% @spec command_build_option_spec_list() -> ok
%% @end
%%------------------------------------------------------------------------------
command_build_option_spec_list() ->
    [
     %% {Name, ShortOpt, LongOpt, ArgSpec, HelpMsg}
     {help,         $h,         "help",         undefined,
        "Show the program options"},
     {tree_name,    undefined,  undefined,      atom,
        "Tree name for rtree server (gen_server and ets)."}
    ].

%%------------------------------------------------------------------------------
%% @doc
%% Command intersects specific option specification list
%%
%% @spec command_filter_option_spec_list() -> ok
%% @end
%%------------------------------------------------------------------------------
command_filter_option_spec_list() ->
    [
     %% {Name, ShortOpt, LongOpt, ArgSpec, HelpMsg}
     {help,         $h,         "help",         undefined,
        "Show the program options"},
     {tree_name,    undefined,  undefined,      atom,
        "Tree name for rtree server (gen_server and ets)."},
     {script_file,    undefined,  undefined,      string,
        "Erlang file with fun(E, Point) function (.erl)."},
     {input_file,    undefined,  undefined,      string,
        "Input file with longitude,latitude values to intersect (.csv.gz)."},
     {output_file,    undefined,  undefined,      string,
        "Output file with longitude,latitude values to intersect (.csv.gz)."}
    ].

%%------------------------------------------------------------------------------
%% @doc
%% Command lookup specific option specification list
%%
%% @spec command_lookup_option_spec_list() -> ok
%% @end
%%------------------------------------------------------------------------------
command_lookup_option_spec_list() ->
    [
     %% {Name, ShortOpt, LongOpt, ArgSpec, HelpMsg}
     {help,         $h,         "help",         undefined,
        "Show the program options"},
     {tree_name,    undefined,  undefined,      atom,
        "Tree name for rtree server (gen_server and ets)."},
     {id,    undefined,  undefined,      string,
        "Id to lookup."},
     {id_type,    undefined,  undefined,      atom,
        "Data type for the id. Options string, float, integer, binary."}
    ].

%%------------------------------------------------------------------------------
%% @doc
%% Command delete specific option specification list
%%
%% @spec command_delete_option_spec_list() -> ok
%% @end
%%------------------------------------------------------------------------------
command_delete_option_spec_list() ->
    [
     %% {Name, ShortOpt, LongOpt, ArgSpec, HelpMsg}
     {help,         $h,         "help",         undefined,
        "Show the program options"},
     {tree_name,    undefined,  undefined,      atom,
        "Tree name for rtree server (gen_server and ets)."},
     {id,    undefined,  undefined,      string,
        "Id to lookup."},
     {id_type,    undefined,  undefined,      atom,
        "Data type for the id. Options string, float, integer, binary."}
    ].

%%------------------------------------------------------------------------------
%% @doc
%% Command intersects specific option specification list
%%
%% @spec command_intersects_option_spec_list() -> ok
%% @end
%%------------------------------------------------------------------------------
command_intersects_option_spec_list() ->
    [
     %% {Name, ShortOpt, LongOpt, ArgSpec, HelpMsg}
     {help,         $h,         "help",         undefined,
        "Show the program options"},
     {tree_name,    undefined,  undefined,      atom,
        "Tree name for rtree server (gen_server and ets)."},
     {input_file,    undefined,  undefined,      string,
        "Input file with longitude,latitude values to intersect (.csv.gz)."},
     {output_file,    undefined,  undefined,      string,
        "Output file with longitude,latitude values to intersect (.csv.gz)."}
    ].

%%------------------------------------------------------------------------------
%% @doc
%% Command doall specific option specification list
%%
%% @spec command_doall_option_spec_list() -> ok
%% @end
%%------------------------------------------------------------------------------
command_doall_option_spec_list() ->
    [
     %% {Name, ShortOpt, LongOpt, ArgSpec, HelpMsg}
     {help,         $h,         "help",         undefined,
        "Show the program options"},
     {dsn,    undefined,  undefined,      string,
        "Data source name."},
     {input_file,    undefined,  undefined,      string,
        "Input file with longitude,latitude values to intersect (.csv.gz)."},
     {output_file,    undefined,  undefined,      string,
        "Output file with longitude,latitude values to intersect (.csv.gz)."}
    ].


%%------------------------------------------------------------------------------
%% @doc
%% Parse command line arguments
%%
%% @spec parse_args(RawArgs) -> {Options, Args}
%% @end
%%------------------------------------------------------------------------------
parse_args(RawArgs) ->
    %% Parse getopt options
    OptSpecList = main_option_spec_list(),
    case getopt:parse_and_check(OptSpecList, RawArgs) of
        {ok, {Options, Args}} ->
            case lists:any(
                fun(Elem) -> case Elem of help -> true; _ -> false end end,
                Options) of
                true ->
                    usage(),
                    delayed_halt(1);
                false -> false
            end,
            case proplists:get_value(verbose, Options) of
                debug ->
                    lager:set_loglevel(lager_console_backend, debug);
                info ->
                    lager:set_loglevel(lager_console_backend, info);
                warning ->
                    lager:set_loglevel(lager_console_backend, warning);
                error ->
                    lager:set_loglevel(lager_console_backend, error);
                _ ->
                    lager:error("Verbose option given is not valid."),
                    delayed_halt(1)
            end,
            %% SubArgs contains Args, if appending is done then values
            %% will be replicated
            case  proplists:get_value(command, Options) of
                build ->
                    {SubOptions, SubArgs} = command_parse_args(Args,
                        fun command_build_option_spec_list/0,
                        fun command_build_usage/0),
                    MergedOptions = lists:append(Options, SubOptions),
                    {MergedOptions, SubArgs};
                create ->
                    {SubOptions, SubArgs} = command_parse_args(Args,
                        fun command_create_option_spec_list/0,
                        fun command_create_usage/0),
                    MergedOptions = lists:append(Options, SubOptions),
                    {MergedOptions, SubArgs};
                delete ->
                    {SubOptions, SubArgs} = command_parse_args(Args,
                        fun command_delete_option_spec_list/0,
                        fun command_delete_usage/0),
                    MergedOptions = lists:append(Options, SubOptions),
                    {MergedOptions, SubArgs};
                doall->
                    {SubOptions, SubArgs} = command_parse_args(Args,
                        fun command_doall_option_spec_list/0,
                        fun command_doall_usage/0),
                    MergedOptions = lists:append(Options, SubOptions),
                    {MergedOptions, SubArgs};
                filter ->
                    {SubOptions, SubArgs} = command_parse_args(Args,
                        fun command_filter_option_spec_list/0,
                        fun command_filter_usage/0),
                    MergedOptions = lists:append(Options, SubOptions),
                    {MergedOptions, SubArgs};
                intersects ->
                    {SubOptions, SubArgs} = command_parse_args(Args,
                        fun command_intersects_option_spec_list/0,
                        fun command_intersects_usage/0),
                    MergedOptions = lists:append(Options, SubOptions),
                    {MergedOptions, SubArgs};
                insert ->
                    {SubOptions, SubArgs} = command_parse_args(Args,
                        fun command_insert_option_spec_list/0,
                        fun command_insert_usage/0),
                    MergedOptions = lists:append(Options, SubOptions),
                    {MergedOptions, SubArgs};

                load ->
                    {SubOptions, SubArgs} = command_parse_args(Args,
                        fun command_load_option_spec_list/0,
                        fun command_load_usage/0),
                    MergedOptions = lists:append(Options, SubOptions),
                    {MergedOptions, SubArgs};
                lookup ->
                    {SubOptions, SubArgs} = command_parse_args(Args,
                        fun command_lookup_option_spec_list/0,
                        fun command_lookup_usage/0),
                    MergedOptions = lists:append(Options, SubOptions),
                    {MergedOptions, SubArgs};
                undefined ->
                    lager:error("Missing argument <command>."),
                    usage(),
                    delayed_halt(1);
                Other ->
                    lager:warning("Wrong argument <command>: ~p", [Other]),
                    usage(),
                    delayed_halt(1)
            end;
        {error, {Reason, Data}} ->
            lager:error("~s ~p~n~n", [Reason, Data]),
            usage(),
            delayed_halt(1)
    end.

%%------------------------------------------------------------------------------
%% @doc
%% Parse command line arguments according to input functions
%%
%% @spec command_parse_args(ParserArgs, OptionSpecListFun, UsageFun) ->
%%  {Options, Args}
%% @end
%%------------------------------------------------------------------------------
command_parse_args(ParserArgs, OptionSpecListFun, UsageFun) ->
    OptSpecList = OptionSpecListFun(),
    case getopt:parse_and_check(OptSpecList, ParserArgs) of
        {ok, {Options, Args}} ->
            case lists:any(
                fun(Elem) -> case Elem of help -> true; _ -> false end end,
                Options) of
                true ->
                    UsageFun(),
                    delayed_halt(1);
                false -> {Options, Args}
            end;
        {error, {Reason, Data}} ->
            lager:error("~s ~p~n~n", [Reason, Data]),
            UsageFun(),
            delayed_halt(1)
    end.

%% ====================================================================
%% Execution
%% ====================================================================

%%------------------------------------------------------------------------------
%% @doc
%% Read raw arguments parse them and execute command
%%
%% @spec run(RawArgs) -> ok
%% @end
%%------------------------------------------------------------------------------
run(RawArgs) ->
    {Options, Args} = parse_args(RawArgs),
    run_command(proplists:get_value(command, Options), Options, Args).

%%------------------------------------------------------------------------------
%% @doc
%% Run specific command 
%%
%% @spec run_command(create, Options, Args) -> ok
%% @end
%%------------------------------------------------------------------------------
run_command(create, Options, _Args) ->
    lager:debug("rtree_client:create options: ~p", [Options]),
    RemoteNode = connect(Options),
    TreeName = proplists:get_value(tree_name, Options),
    case rtree_call(RemoteNode, rtree_supervisor, create, [TreeName]) of
        {error, Reason} ->
            lager:error("~p", [Reason]),
            delayed_halt(1);
        Response ->
            lager:info("~p", [Response]),
            delayed_halt(0)
    end;
%%------------------------------------------------------------------------------
%% @doc
%% Run specific command 
%%
%% @spec run_command(insert, Options, Args) -> ok
%% @end
%%------------------------------------------------------------------------------
run_command(insert, Options, Args) ->
    lager:debug("rtree_client:insert options: ~p, args: ~p", [Options, Args]),
    RemoteNode = connect(Options),
    IdIndex = proplists:get_value(idindex, Options),
    Dsn = proplists:get_value(dsn, Options),
    TreeName = proplists:get_value(tree_name, Options),
    ServerName = list_to_atom("rtree_server_" ++ atom_to_list(TreeName)),
    %% TODO:Geometries lazy loading
    RecordList = case rtree:load_to_list(Dsn, IdIndex) of
        {ok, Records} ->
            Records; 
        {error, Reason1} ->
            lager:error("~p", [Reason1]),
            delayed_halt(1)
    end,
    %% TODO:Geometries could be validated before inserting
    NumberInserted = lists:foldl(
        fun(R, Acc) ->
            case rtree_call(RemoteNode, ServerName, insert, [TreeName, [R]]) of
                {error, Reason2} ->
                    lager:error("~p for record ~p", [Reason2, R]),
                    Acc;
                Response ->
                    lager:debug("Inserted: ~p", [Response]),
                    Acc + 1
            end
        end,
        0,
        RecordList
    ),
    lager:info("Records inserted ~p of ~p",
        [NumberInserted, length(RecordList)]),
    delayed_halt(0);
%%------------------------------------------------------------------------------
%% @doc
%% Run specific command 
%%
%% @spec run_command(filter, Options, Args) -> ok
%% @end
%%------------------------------------------------------------------------------
run_command(filter, Options, Args) ->
    lager:debug("rtree_client:filter Options:~p Args:~p~n", [Options, Args]),
    RemoteNode = connect(Options),
    ScriptPath = filename:absname(proplists:get_value(script_file, Options)),
    InputPath = filename:absname(proplists:get_value(input_file, Options)),
    OutputPath = filename:absname(proplists:get_value(output_file, Options)),
    TreeName = proplists:get_value(tree_name, Options),
    ServerName = list_to_atom("rtree_server_" ++ atom_to_list(TreeName)),
    %% Filter must return true
    %% Filter = "fun(E, Point) -> erlgeom:intersects(element(3, E), Point) end.",
    {ok, Data} = file:read_file(ScriptPath),
    Filter = binary:bin_to_list(Data),
    _Res = case rtree_call(RemoteNode, ServerName, pfilter_file,
        [TreeName, InputPath, OutputPath, self(), Filter]) of
        {error, Reason} ->
            lager:error("~p", [Reason]),
            delayed_halt(1);
        Response ->
            lager:info("~p", [Response]),
            Response
    end,
    receive
        {ok, InputFile} ->
            lager:info("Done processing input file: ~p", [InputFile]);
        Other ->
            lager:info("Done: ~p", [Other])
    end,
    delayed_halt(0);
%%------------------------------------------------------------------------------
%% @doc
%% Run specific command 
%%
%% @spec run_command(lookup, Options, Args) -> ok
%% @end
%%------------------------------------------------------------------------------
run_command(lookup, Options, Args) ->
    lager:debug("rtree_client:lookup Options:~p Args:~p~n", [Options, Args]),
    RemoteNode = connect(Options),
    IdString = proplists:get_value(id, Options),
    IdType = proplists:get_value(id_type, Options),
    Id = case IdType of
        string -> IdString;
        float -> list_to_float(IdString);
        integer -> list_to_integer(IdString);
        binary -> list_to_binary(IdString)
    end,
    TreeName = proplists:get_value(tree_name, Options),
    ServerName = list_to_atom("rtree_server_" ++ atom_to_list(TreeName)),
    %% Filter must return true
    _Res = case rtree_call(RemoteNode, ServerName, lookup,
        [TreeName, Id, self()]) of
        {error, Reason} ->
            lager:error("~p", [Reason]),
            delayed_halt(1);
        Response ->
            lager:info("~p", [Response]),
            Response
    end,
    receive
        {Pid, Records} ->
            lager:info("Done processing from pid ~p: ~p", [Pid, Records]);
        Other ->
            lager:info("Done: ~p", [Other])
    end,
    delayed_halt(0);
%%------------------------------------------------------------------------------
%% @doc
%% Run specific command 
%%
%% @spec run_command(delete, Options, Args) -> ok
%% @end
%%------------------------------------------------------------------------------
run_command(delete, Options, Args) ->
    lager:debug("rtree_client:delete Options:~p Args:~p~n", [Options, Args]),
    RemoteNode = connect(Options),
    IdString = proplists:get_value(id, Options),
    IdType = proplists:get_value(id_type, Options),
    Id = case IdType of
        string -> IdString;
        float -> list_to_float(IdString);
        integer -> list_to_integer(IdString);
        binary -> list_to_binary(IdString)
    end,
    TreeName = proplists:get_value(tree_name, Options),
    ServerName = list_to_atom("rtree_server_" ++ atom_to_list(TreeName)),
    %% Filter must return true
    _Res = case rtree_call(RemoteNode, ServerName, delete,
        [TreeName, Id, self()]) of
        {error, Reason} ->
            lager:error("~p", [Reason]),
            delayed_halt(1);
        Response ->
            lager:info("~p", [Response]),
            Response
    end,
    receive
        {Pid, Deleted} ->
            lager:info("Done processing from pid ~p: ~p", [Pid, Deleted]);
        Other ->
            lager:info("Done: ~p", [Other])
    end,
    delayed_halt(0);
%%------------------------------------------------------------------------------
%% @doc
%% Run specific command 
%%
%% @spec run_command(load, Options, Args) -> ok
%% @end
%%------------------------------------------------------------------------------
run_command(load, Options, Args) ->
    lager:debug("rtree_client:load options: ~p, args: ~p", [Options, Args]),
    RemoteNode = connect(Options),
    IdIndex = proplists:get_value(idindex, Options),
    Dsn = proplists:get_value(dsn, Options),
    TreeName = proplists:get_value(tree_name, Options),
    ServerName = list_to_atom("rtree_server_" ++ atom_to_list(TreeName)),
    case rtree_call(RemoteNode, ServerName, load, [TreeName, Dsn, IdIndex]) of
        {error, Reason} ->
            lager:error("~p", [Reason]),
            delayed_halt(1);
        Response ->
            lager:info("~p", [Response]),
            delayed_halt(0)
    end;
%%------------------------------------------------------------------------------
%% @doc
%% Run specific command 
%%
%% @spec run_command(build, Options, Args) -> ok
%% @end
%%------------------------------------------------------------------------------
run_command(build, Options, Args) ->
    lager:debug("Run build: ~p~p~n", [Options, Args]),
    RemoteNode = connect(Options),
    TreeName = proplists:get_value(tree_name, Options),
    ServerName = list_to_atom("rtree_server_" ++ atom_to_list(TreeName)),
    case rtree_call(RemoteNode, ServerName, build, [TreeName]) of
        {error, Reason} ->
            lager:error("~p", [Reason]),
            delayed_halt(1);
        Response ->
            lager:info("~p", [Response]),
            delayed_halt(0)
    end;
%%------------------------------------------------------------------------------
%% @doc
%% Run specific command 
%%
%% @spec run_command(intersects, Options, Args) -> ok
%% @end
%%------------------------------------------------------------------------------
run_command(intersects, Options, Args) ->
    lager:debug("rtree_client:intersects Options:~p Args:~p~n", [Options, Args]),
    RemoteNode = connect(Options),
    InputPath = filename:absname(proplists:get_value(input_file, Options)),
    OutputPath = filename:absname(proplists:get_value(output_file, Options)),
    TreeName = proplists:get_value(tree_name, Options),
    ServerName = list_to_atom("rtree_server_" ++ atom_to_list(TreeName)),
    _Res = case rtree_call(RemoteNode, ServerName, pintersects_file,
        [TreeName, InputPath, OutputPath, self()]) of
        {error, Reason} ->
            lager:error("~p", [Reason]),
            delayed_halt(1);
        Response ->
            lager:info("~p", [Response]),
            Response
    end,
    receive
        {ok, InputFile} ->
            lager:info("Done processing input file: ~p", [InputFile]);
        Other ->
            lager:info("Done: ~p", [Other])
    end,
    delayed_halt(0);
 
%%------------------------------------------------------------------------------
%% @doc
%% Run intersects in local mode executing create, load, build, and intersects
%%
%% @spec run_command(doall, Options, Args) -> ok
%% @end
%%------------------------------------------------------------------------------
run_command(doall, Options, Args) ->
    lager:debug("Running doall with: ~p ~p", [Options, Args]),
    Dsn = proplists:get_value(dsn, Options),
    ok = application:start(rtree_server),
    rtree_server:create(local_tree),
    rtree_server:load(local_tree, Dsn),
    rtree_server:build(local_tree),
    InputPath = filename:absname(proplists:get_value(input_file, Options)),
    OutputPath = filename:absname(proplists:get_value(output_file, Options)),
    Res = rtree_server:intersects_file(local_tree, InputPath, OutputPath),
    lager:info("Response: ~p", [Res]),
    delayed_halt(0).
 
%% ====================================================================
%% Helper Functions
%% ====================================================================

%%------------------------------------------------------------------------------
%% @doc
%% Get the node name from the escript name plus the hostname
%%
%% @spec node_name() -> NodeName::atom
%% @end
%%------------------------------------------------------------------------------
node_name() ->
    Localhost = net_adm:localhost(),
    list_to_atom(?ESCRIPT ++ "@" ++ Localhost).

%%------------------------------------------------------------------------------
%% @doc
%% Get the node sname from plus the hostname
%%
%% @spec node_sname(Name) -> NodeName::atom
%% @end
%%------------------------------------------------------------------------------
node_sname(Name) ->
    Localhost = net_adm:localhost(),
    list_to_atom(Name ++ "@" ++ Localhost).

%%------------------------------------------------------------------------------
%% @doc
%% Setup and test connection to erlang cluster
%%
%% @spec connect(Options) -> RemoteNode::atom
%% @end
%%------------------------------------------------------------------------------
connect(Options) ->
    lager:debug("Connecting with options: ~p~n", [Options]),
    NodeName = proplists:get_value(node_name, Options),
    Cookie = proplists:get_value(cookie, Options),
    RemoteNode = proplists:get_value(remote_node, Options),
    net_kernel:start([NodeName, shortnames]),
    erlang:set_cookie(NodeName, Cookie),
    case net_adm:ping(RemoteNode) of
        pong ->
            lager:debug("~s: ~s ~p", [?ESCRIPT, NodeName, pong]),
            %net_kernel:connect_node(RemoteNode),
            lager:debug("Remote node: ~p", [RemoteNode]),
            RemoteNode;
        Else ->
            lager:debug("~s: ~s ~p", [?ESCRIPT, NodeName, Else]),
            lager:error("Connecting to remote node: ~p", [RemoteNode]),
            delayed_halt(1)
    end.

%%------------------------------------------------------------------------------
%% @doc
%% Helerper function to submit rpc call where given resource is found
%%
%% @spec rtree_call(RemoteNode, Resource, Function, Args) -> Response
%% @end
%%------------------------------------------------------------------------------
rtree_call(RemoteNode, Resource, Function, Args) ->
    lager:debug("~p:resource_discovery:get_resource(~p)",
        [RemoteNode, Resource]),
    case rpc:call(RemoteNode, resource_discovery, get_resource, [Resource]) of
        {ok, ServerNode} ->
            lager:debug("Node found: ~p", [ServerNode]),
            Res = rpc:call(ServerNode, rtree_server, Function, Args),
            lager:debug("~p:rtree_server:~p ~p",
                [ServerNode, Function, Args]),
            lager:debug("Response: ~p", [Res]),
            Res;
        {error, not_found} ->
            lager:error("Resource ~p not found in node ~p",
               [Resource, RemoteNode]),
            {error, "Resource not found in node"}
    end.



%%------------------------------------------------------------------------------
%% @doc
%% From rebar_utils.erl
%% Work around buffer flushing issue in erlang:halt if OTP older than R15B01.
%% TODO: remove workaround once we require R15B01 or newer R15B01 introduced
%% erlang:halt/2
%%
%% @spec delayed_halt(integer()) -> no_return()
%% @end
%%------------------------------------------------------------------------------
delayed_halt(Code) ->
    case erlang:is_builtin(erlang, halt, 2) of
        true ->
            timer:sleep(100),
            halt(Code);
        false ->
            case os:type() of
                {win32, nt} ->
                    timer:sleep(100),
                    halt(Code);
                _ ->
                    halt(Code),
                    %% workaround to delay exit until all output is written
                    receive after infinity -> ok end
            end
    end.
