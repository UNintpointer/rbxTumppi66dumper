What is hookmetamethod?
To understand what hookmetamethod is and what it does, we must first understand what a "metamethod" is. A metamethod is a special function used to control the behavior of certain methods on a table. 
Lua has multiple different metamethods, here is a list of some of them: 

  “__add” defines the behaviour of addition operator (‘+’). 

  “__sub” defines the behaviour of substraction operator (‘-’). 

  “__mul” defines the behaviour of multiplication operator (‘*’). 

  “__div” defines the behaviour of division operator (‘/’). 

  “__eq” defines the behaviour for equality comparison (‘==’). 

  “__lt” defines the behaviour for less-than comparison (‘<’). 

  “__le” defines the behaviour for less-than or equal comparison (‘<=’). 

  “__index” allows customization of table indexing. 

  “__newindex” allows customization of table assignment. 

Here is an example of how we can modify the behaviour of “__add” metamethod: 
