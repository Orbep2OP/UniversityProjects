package game.elements;
import utils.Point2D;

public interface Movable {
	public Point2D Move(Point2D p);

	public void attack(GameElement GE);

	public void attacked(GameElement GE);

	public boolean isDead();
}

