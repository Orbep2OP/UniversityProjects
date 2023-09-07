package game.elements;


import utils.Point2D;

public class Wall extends GameElement {

	public Wall(Point2D p) {
		super(p);
		super.setLayer(1);
		super.setName("Wall");
	}
}
