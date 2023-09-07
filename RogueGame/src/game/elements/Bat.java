package game.elements;

import graphics.GameEngine;
import utils.Direction;
import utils.Point2D;
import utils.Vector2D;

public class Bat extends GameElement implements Movable{

	private int hitpoints;

	public Bat(Point2D p) {
		super(p);
		super.setLayer(1);
		super.setName("Bat");
		this.hitpoints = 3;
	}

	public Point2D Move(Point2D p) {

		int distanciaX = p.getX() - this.getPosition().getX();
		int distanciaY = p.getY() - this.getPosition().getY();

		int x = 0;
		int y = 0;

		
		if (Math.random() < 0.5) {
			
			if( distanciaX == 0 && distanciaY == 0 ) {
				return super.getPosition();
			}

			if( distanciaX == 0 && distanciaY > 0) {
				x = super.getPosition().getX();
				y = (super.getPosition().getY() + 1);
				return new Point2D(x,y);
			}

			if( distanciaX == 0 && distanciaY < 0) {
				x = super.getPosition().getX();
				y = (super.getPosition().getY() - 1);
				return new Point2D(x,y);
			}

			if( distanciaY == 0 && distanciaX > 0) {
				x = (super.getPosition().getX() + 1);
				y = super.getPosition().getY();
				return new Point2D(x,y);
			}

			if( distanciaY == 0 && distanciaX < 0) {
				x = (super.getPosition().getX() - 1);
				y = super.getPosition().getY();
				return new Point2D(x,y);
			}

			int xAux = distanciaX - super.getPosition().getX();
			int yAux = distanciaY - super.getPosition().getY();

			if(Math.abs(xAux) <= Math.abs(yAux)) {
				if(distanciaX > 0) {
					x = (super.getPosition().getX() + 1);
					y = super.getPosition().getY();
					return new Point2D(x,y);
				}
				else {
					x = (super.getPosition().getX() - 1);
					y = super.getPosition().getY();
					return new Point2D(x,y);
				}
			}

			if(distanciaY > 0) {
				x = super.getPosition().getX();
				y = (super.getPosition().getY() + 1);
				return new Point2D(x,y);
			}

			x = super.getPosition().getX();
			y = (super.getPosition().getY() - 1);
			return new Point2D(x,y);

		}

		Direction randDirection = Direction.random();
		Vector2D randVector = randDirection.asVector(); 
		Point2D pAfterMove = super.getPosition().plus(randVector);
		return pAfterMove;

	}

	@Override
	public void attacked(GameElement GE) {
		if(((Hero) GE).hasItem("Sword")) {
			this.hitpoints = this.hitpoints - 2;
		}
		else {
			this.hitpoints = this.hitpoints - 1;
		}

		if(isDead()) {
			GameEngine.getInstance().updatePoints(3);
			GameEngine.getInstance().removeElement(this);
		}
	}

	@Override
	public void attack(GameElement GE) {
		GameEngine.getInstance().updatePoints(-1);
		((Hero) GE).attacked(this);
	}

	public int getAttackPower() {
		int aux = this.hitpoints + 1;

		if(Math.random() < 0.5) {
			if(aux >= 3) {
				this.hitpoints = 3;
			}
			else {
				this.hitpoints = aux;
			}
			return 1;
		}
		return 0;
	}

	@Override
	public boolean isDead() {
		return (hitpoints <= 0);
	}

}
