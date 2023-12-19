import java.awt.Color;
import org.junit.*;
import static org.junit.Assert.*;

/**
 * 
 * @author Mathis Sigier mathis.sigier@etu.inp-n7.fr
 * Groupe L
 */

public class CercleTest {

	/** @param EPSILON Constante de précision */
	public final static double EPSILON = 10e-2;

	/** Nommage des points pour les tests */
	private Point A, B, C;

	/** Nommage des cercles pour les test */
	private Cercle C1,C2,C3;
	
	/** Construire les cercles et les points utiles pour les tests. */
	@Before public void setUp() {
		/** Construction des points pour les tests */
		A = new Point(2, 1);
		B = new Point(0, 8);
		C = new Point(4, -6);

		/** Construction des cercles pour les tests */
		C1 = new Cercle(C, B);
		C2 = new Cercle(C,B,Color.red);
		C3 = Cercle.creerCercle(A,B); // C3 est formé par son centre A et B un point du cercle.

	}
	
	
	static void memePoint(String message, Point point1, Point point2) {
		assertEquals(message + " (x)", point1.getX(), point2.getX(), EPSILON);
		assertEquals(message + " (y)", point1.getY(), point2.getY(), EPSILON);
	}
	

	@Test public void testerE12() {
		memePoint("E12 : Le centre n'est pas correct", C1.getCentre(), A);
		assertEquals("E12 : Le rayon est incorrect",C1.getRayon(), 7.280, 0.1d);
		assertEquals("E12 : La couleur est incorrect",C1.getCouleur(), Color.blue);
		}
	
	
	@Test public void testerE13() {
		memePoint("E13 : Le centre n'est pas correct", C2.getCentre(), A);
		assertEquals("E13 : Le rayon est incorrect",C2.getRayon(), 7.280, 0.1d);
		assertEquals("E13 : La couleur est incorrect",C2.getCouleur(), Color.red);
	}
	
	
	@Test public void testerE14() {
		memePoint("E13 : Le centre n'est pas correct", C3.getCentre(), A);
		assertEquals("E13 : Le rayon est incorrect",C3.getRayon(), 7.280, 0.1d);
		assertEquals("E13 : La couleur est incorrect",C3.getCouleur(), Color.blue);
	}
	
	
	
}