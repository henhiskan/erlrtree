#! /usr/bin/env python

# Copyright 2013 Carlos Roman
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.


import argparse
import logging
import sys
import Queue

import erlrtree.node
from erlrtree.node import NodeHelper

LOGGER = None

def main(argv):
    """
    Mainf function with argument parsing.
    """

    desc = "ErlRTree python client."
    parser = argparse.ArgumentParser(description = desc)

    parser.add_argument('--version', action='version', version='1.0.0')

    parser.add_argument("-v", '--verbose'
        ,metavar='verbose'
        ,action='store'
        ,dest='verbose'
        ,default='warning'
        ,choices=['debug', 'info', 'warning', 'error', 'critical']
        ,help="Enable debugging. Levels %(choices)s. Default %(default)s.")

    parser.add_argument("-n", "--python_node_name"
        ,default="py_rtree"
        ,help="Set the python node's <name|sname>. Default %(default)s.")

    parser.add_argument("-c", "--cookie"
        ,default="rtree"
        ,help="Set cookie. Default %(default)s.")

    parser.add_argument("--remote_node"
        ,default="rtree@127.0.0.1"
        ,help="Node <name|sname> to connect to. Default %(default)s.")

    parser.add_argument("-t", "--timeout"
        ,default=10
        ,help="""Timeout for response. Default %(default)s seconds.
            If timeout is `0` then no timeout is set.""")


    subparsers = parser.add_subparsers(help='ErlRTree actions.')

    parser_create = subparsers.add_parser('create', help='Create an rtree server.')
    parser_create.set_defaults(action='create')

    parser_create.add_argument("tree_name"
        ,help="""Server name of tree to query.""")

    parser_load = subparsers.add_parser('load', help='Load a datasource.')
    parser_load.set_defaults(action='load')

    parser_load.add_argument("tree_name"
        ,help="""Server name of tree to query.""")

    parser_load.add_argument('dsn',
        metavar='DSN',
        help='OGR Data Source Name to load.')

    parser_build = subparsers.add_parser('build',
        help='Build STRTree from loaded DSNs.')
    parser_build.set_defaults(action='build')

    parser_build.add_argument("tree_name"
        ,help="""Server name of tree to query.""")

    parser_build.add_argument('filter',
        default=None,
        nargs='?',
        help='Filter to apply on elements before creating tree.')

    parser_intersects = subparsers.add_parser('intersects',
        help='Query for intersects.')
    parser_intersects.set_defaults(action='intersects')

    parser_intersects.add_argument("tree_name"
        ,help="""Server name of tree to query.""")

    parser_intersects.add_argument('points',
        metavar="'X,Y'",
        nargs='+',
        help="Point 'X,Y' (Longitude,Latitude) to intersect with RTree.")

    args = parser.parse_args(argv[1:])

    # Prepare logging
    global LOGGER
    log_format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    logging.basicConfig(format=log_format)
    LOGGER = logging.getLogger("py_rtree")
    if args.verbose == 'debug':
        LOGGER.setLevel(logging.DEBUG)
    elif args.verbose == 'info':
        LOGGER.setLevel(logging.INFO)
    elif args.verbose == 'warning':
        LOGGER.setLevel(logging.WARNING)
    elif args.verbose == 'error':
        LOGGER.setLevel(logging.ERROR)
    elif args.verbose == 'critical':
        LOGGER.setLevel(logging.CRITICAL)
    else:
        LOGGER.setLevel(logging.ERROR)

    # Main Process
    # Prepare RPC mfa (module, function, [arg1, ...])
    
    if args.action == "create":
        module_name = 'rtree_server'
        function_name = 'create'
        function_args = ["'%s'" % args.tree_name]

        # Translate arguments to erlang types
        erlang_args = erlrtree.node.args_to_erlargs(function_args)

        # Create, start, and connect python node
        LOGGER.info("Connecting node")
        node_helper = NodeHelper(args.python_node_name,
            args.cookie,
            args.timeout,
            args.verbose == "debug")
        try:
            msg = node_helper.send_sync_rpc(args.remote_node,
                module_name,
                function_name,
                erlang_args,
                args.timeout)
        except erlrtree.node.Timeout as error:
            LOGGER.error(error)
            return 1
        print "RESPONSE", msg
    elif args.action == "load":
        module_name = 'rtree_server'
        function_name = 'load'
        function_args = ["'%s'" % args.tree_name, args.dsn]

        # Translate arguments to erlang types
        erlang_args = erlrtree.node.args_to_erlargs(function_args)

        # Create, start, and connect python node
        LOGGER.info("Connecting node")
        node_helper = NodeHelper(args.python_node_name,
            args.cookie,
            args.timeout,
            args.verbose == "debug")
        try:
            msg = node_helper.send_sync_rpc(args.remote_node,
                module_name,
                function_name,
                erlang_args,
                args.timeout)
        except erlrtree.node.Timeout as error:
            LOGGER.error(error)
            return 1
        print "RESPONSE", msg

    elif args.action == "build":
        module_name = 'rtree_server'
        function_name = 'tree'
        function_args = ["'%s'" % args.tree_name]

        # Translate arguments to erlang types
        erlang_args = erlrtree.node.args_to_erlargs(function_args)

        # Create, start, and connect python node
        LOGGER.info("Connecting node")
        node_helper = NodeHelper(args.python_node_name,
            args.cookie,
            args.timeout)
        try:
            msg = node_helper.send_sync_rpc(args.remote_node,
                module_name,
                function_name,
                erlang_args)
        except erlrtree.node.Timeout as error:
            LOGGER.error(error)
            return 1
        print "RESPONSE", msg

    elif args.action == 'intersects':
        module_name = 'rtree_server'
        function_name = 'intersects'
        function_args = ["'%s'" % args.tree_name] + [map(float, point.split(","))
            for point in args.points]
        # Translate arguments to erlang types
        erlang_args = erlrtree.node.args_to_erlargs(function_args)
        tree_erlang_arg = erlang_args[0]
        point_erlang_args = erlang_args[1:]

        # Create, start, and connect python node
        LOGGER.debug("Connecting node")
        node_helper = NodeHelper(args.python_node_name,
            args.cookie,
            args.timeout)

        rpcs = [(args.remote_node, module_name, function_name,
            [tree_erlang_arg] + point_erlang_arg)
            for point_erlang_arg in point_erlang_args]

        output_queue = node_helper.send_async_rpcs(rpcs)
        
        LOGGER.info("Waiting for messages. Timeout between messages: %s (s)",
            args.timeout)
        counter = len(rpcs)
        while counter:
            try:
                msg = output_queue.get(True, args.timeout)
            except Queue.Empty as error:
                LOGGER.debug("Empty queue: %s", error)
                continue
            print "RESPONSE", msg
            counter -= 1
    else:
        print "Action not understood."

    LOGGER.info("Disconnecting node")
    return 0

if __name__ == "__main__":
    sys.exit(main(sys.argv))
