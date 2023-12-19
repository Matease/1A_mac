import java.awt.Color;

/**
 * @author Mathis Sigier mathis.sigier@etu.inp-n7.fr
 * groupe L
 */
public class Cercle implements Mesurable2D {

	/** @param Pi Constante PI. */
	public static final double PI = Math.PI;

	/** @param rayon.*/
	private double rayon;
	/** @param centre.*/
	private Point centre;
	/** @param Couleur.*/
	private Color couleur;

	/** Construire un cercle à partir d'un point qui est le centre ainsi que son rayon.
	 * @param vc Centre_du_cercle
	 * @param r	rayon_du_cercle
	 */

	public Cercle(Point vc, double r) {
		assert (vc != null);
		assert (r > 0);
		assert (r != 0);
		double xcentre = vc.getX();
		double ycentre = vc.getY();
		this.centre = new Point(xcentre, ycentre);
		this.rayon = r;
		this.couleur = Color.blue;

	}

	/** Obtenir le centre du cercle .
	 *@return Le point Centre du cercle
	 */
	public Point getCentre() {
		double xcentre = centre.getX();
		double ycentre = centre.getY();
		Point Centre = new Point(xcentre, ycentre);
		return Centre;
	}

	/** Obtenir le rayon du cercle.
	 *@return Rayon
	 */
	public double getRayon() {
		return this.rayon;
	}

	/** Obtenir le diamètre du cercle.
	 *@return diamètre
	 */
	public double getDiametre() {
		return (2 * this.rayon);
	}

	/** Modifier le rayon du cercle.
	 *@param r Rayon
	 */
	public void setRayon(double r) {
		assert (r > 0);
		this.rayon = r;
	}

	/** Modifier le diamètre du cercle.
	 *@param d Diamètre
	 */
	public void setDiametre(double d) {
		assert (d > 0);
		this.rayon = d / 2;
	}


	/** Translater le cercle.
	 *@param dx déplacement_suivant_l_axe_des_abscisses
	 *@param dy déplacement_suivant_l_axe_des_ordonnees
	 */
	public void translater(double dx, double dy) {
		this.centre.translater(dx, dy);

	}
	/** Obtenir la couleur du cercle.
	 *@return Couleur Couleur_du_cercle
	 */
	public Color getCouleur() {
		return this.couleur;
	}

	/** Changer la couleur du cercle.
	  * @param nouvelleCouleur nouvelle_couleur
	  */
	public void setCouleur(Color nouvelleCouleur) {
		assert (nouvelleCouleur != null);
		this.couleur = nouvelleCouleur;
	}

	/** Obtenir le périmètre du cercle.
	 * @return p perimetre_du_cercle
	 */
	public double perimetre() {
		return 2 * Math.PI * this.rayon;
	}

	/** Obtenir l'air du cercle.
	 * @return aire aire_du_cercle
	 */
	public double aire() {
		return Math.PI * Math.pow(this.rayon, 2);
	}

	/** Créer cercle avec 2 pts diametralement opposés,la couleur est bleue.
	 * @param p1
	 * @param p2
	 */
	public Cercle(Point p1, Point p2) {
		assert (p1 != null);
		assert (p2 != null);
		assert (p1.distance(p2) != 0);
		double Rayon = p1.distance(p2) / 2;
		this.rayon = Rayon;
		double xcentre = (p1.getX() + p2.getX()) / 2;
		double ycentre = (p1.getY() + p2.getY()) / 2;
		this.centre = new Point(xcentre, ycentre);
		this.couleur = Color.blue;
	}

	/** Créer cercle à partir de 2 points diametralement opposés et d'une couleur choisie.
	 * @param p1
	 * @param p2
	 * @param col Couleur_du_cercle
	 */
	public Cercle(Point p1, Point p2, Color col) {
		assert (p1 != null);
		assert (p2 != null);
		assert (p1.distance(p2) != 0);
		assert (col != null);
		this.rayon = p1.distance(p2) / 2;
		double xcentre = (p1.getX() + p2.getX()) / 2;
		double ycentre = (p1.getY() + p2.getY()) / 2;
		this.centre = new Point(xcentre, ycentre);
		this.couleur = col;
	}

	/** Créer cercle le premier point est le centre, le deuxième est un point du cercle.
	 * @param p1 Point_centre_nouveau_cercle
	 * @param p2 Point_du_cercle
	 * @return Cercle2pts
	 */
	public static Cercle creerCercle(Point p1, Point p2) {
		assert (p1 != null);
		assert (p2 != null);
		double Rayon = p1.distance(p2);
		Cercle Cercle2Pts;
		Cercle2Pts = new Cercle(p1, Rayon);
		Cercle2Pts.setCouleur(Color.blue);
		return Cercle2Pts;
	}

	/** Afficher le cercle sous forme caractères.
	 * @return String Cercle_caractères
	 */
	public String toString() {
		return ("C" + this.rayon + "@" + this.centre.toString());
	}

	/** Savoir si un Point p1 appartient au disque formé par le cercle.
	 * @param p1 point_savoir_si_dans_le_cercle
	 * @return boolean
	 */
	public boolean contient(Point p1) {
		assert (p1 != null);
		return p1.distance(this.centre) <= this.getRayon();
	}

}
