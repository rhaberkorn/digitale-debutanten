/*
 * Queue data structure
 */
public class Queue {
	Element head @=> Element @tail;

	fun void
	push(Object @data)
	{
		new Element @=> tail.next @=> tail;
		data @=> tail.payload;
	}

	fun Object @
	peek()
	{
		if (head.next == null)
			/* empty */
			return null;
		else
			return head.next.payload;
	}

	fun Object @
	pop()
	{
		head.next @=> Element @el;
		if (el == null)
			/* empty */
			return null;

		el.next @=> head.next;
		if (el == tail)
			/* but now it's empty! */
			head @=> tail;
		return el.payload;
	}

	fun void
	flush()
	{
		while (pop() != null);
	}
}
