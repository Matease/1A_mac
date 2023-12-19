/** Une erreur à la compilation !
  * Pourquoi ?
  * @author	Xavier Crégut
  * @version	1.3
  */
public class ExempleErreur {

	/** Méthode principale */
	public static void main(String[] args) {
		Point p1 = new Point(0,0); 
		// la ligne 10 ne compilait pas car il n'y avait pas d'argument pour le constructeur
		// cela permet de ne pas créer n'importe quelle point
		p1.setX(1);
		p1.setY(2);
		p1.afficher();
		System.out.println();
	}

}
