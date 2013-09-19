erlrtree
========

Rtree server with Geos/STRtree

This is a project to learn and play with Erlang, specially in how integrating
the OGR and GEOS bindings.

Install and Run
---------------

Dependencies
~~~~~~~~~~~~

    * py_interface --  https://github.com:skysbird/py_interface
    * rebar --  https://github.com:basho/rebar
    * GEOS Binding --  https://github.com:caroman/erlgeom
    * OGR Binding --  https://github.com:caroman/erlogr
    * OSR Binding --  https://github.com:caroman/erlosr

Bindings are downloaded using rebar.


Create Node Structure
~~~~~~~~~~~~~~~~~~~~~

    * pushd rel/
    * rebar create-node nodeid=rtree
    * popd


Compile
~~~~~~~

    * rebar get-deps
    * rebar compile generate


Start
~~~~~

    * rel/rtree/bin/rtree start


Usage
-----


erl attach
~~~~~~~~~~

    # rel/rtree/bin/rtree attach
    # rtree_server:load(tree01, "/home/caroman/Projects/caroman/erlrtree/deps/erlogr/test/polygon.shp").
    # rtree_server:tree(tree01).
    # rtree_server:intersects(tree01, 1.0, -1.0).


erl call
~~~~~~~~
    
    # erl_call -c rtree -n rtree@127.0.0.1 -a \
        "rtree_server load [tree01 '\"/home/caroman/Projects/caroman/erlrtree/deps/erlogr/test/polygon.shp\"']"
    # erl_call -c rtree -n rtree@127.0.0.1 -a \
        "rtree_server tree [tree01]"
    # erl_call -c rtree -a -n rtree@127.0.0.1 -a \
        "rtree_server intersects [tree01 1.0 -1.0]"


erlrtree utility
----------------

    # cd utils/py_rtree
    # source setenv
    # erlrtree_client.py load tree01 /home/caroman/Projects/caroman/erlrtree/deps/erlogr/test/polygon.shp
    # erlrtree_client.py build tree01
    # erlrtree_client.py --verbose debug intersects tree01 '1.0,1.0' '1.0,-1.0'
