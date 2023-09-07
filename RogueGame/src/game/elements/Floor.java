package game.elements;

import utils.Point2D;

public class Floor extends GameElement {

	public Floor(Point2D p) {
		super(p);
		super.setLayer(0);
		super.setName("Floor");
	}
}
