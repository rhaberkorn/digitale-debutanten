/*
 * (Double-linked) list data structure with Queue and Stack operations
 */
public class List {
	Element head @=> Element @tail;

	/*
	 * Stack operations
	 */
	fun void
	push(Object @data)
	{
		Element el;
		tail @=> el.prev;
		el @=> tail.next @=> tail;

		data @=> el.payload;
	}

	fun Object @
	getTail()
	{
		/* NOTE: null for tail == head */
		return tail.payload;
	}

	fun Object @
	pop()
	{
		tail @=> Element @el;
		if (el.prev == null)
			/* empty */
			return null;

		el.prev @=> tail;
		null @=> tail.next;

		return el.payload;
	}

	/*
	 * Queue operations
	 */
	fun void
	put(Object @data)
	{
		data => push;
	}

	fun Object @
	getHead()
	{
		if (head.next == null)
			/* empty */
			return null;
		else
			return head.next.payload;
	}

	fun Object @
	get()
	{
		head.next @=> Element @el;
		if (el == null)
			/* empty */
			return null;

		el.next @=> head.next;
		if (el.next == null)
			/* but now it's empty! */
			head @=> tail;
		else
			head @=> el.next.prev;

		return el.payload;
	}

	/*
	 * Common operations
	 */
	fun void
	flush()
	{
		while (pop() != null);
	}
}
